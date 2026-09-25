# Locate nc-config (and, when ENABLE_FORTRAN, nf-config) and provide the
# add_netcdf_example()/add_netcdf_fortran_example()/add_netcdf_run() helpers
# used by every examples/*/CMakeLists.txt.

set(_nc_config_hints "")
if(NETCDF_PREFIX)
    list(APPEND _nc_config_hints ${NETCDF_PREFIX}/bin)
endif()
find_program(NC_CONFIG nc-config HINTS ${_nc_config_hints})
if(NOT NC_CONFIG)
    message(FATAL_ERROR "nc-config not found. Set -DNETCDF_PREFIX=<netcdf install prefix> or add it to PATH.")
endif()

execute_process(COMMAND ${NC_CONFIG} --version OUTPUT_VARIABLE NC_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(COMMAND ${NC_CONFIG} --cflags OUTPUT_VARIABLE NC_CFLAGS OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(COMMAND ${NC_CONFIG} --libs OUTPUT_VARIABLE NC_LIBS OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(COMMAND ${NC_CONFIG} --libdir OUTPUT_VARIABLE NC_LIBDIR OUTPUT_STRIP_TRAILING_WHITESPACE)
message(STATUS "Using ${NC_VERSION} from ${NC_CONFIG}")

separate_arguments(NC_CFLAGS_LIST UNIX_COMMAND "${NC_CFLAGS}")
separate_arguments(NC_LIBS_LIST UNIX_COMMAND "${NC_LIBS}")

# Optional netCDF-C features; each gates an examples subdirectory.
foreach(_feature nczarr dap)
    string(TOUPPER ${_feature} _FEATURE)
    execute_process(COMMAND ${NC_CONFIG} --has-${_feature}
                    OUTPUT_VARIABLE _has RESULT_VARIABLE _rc OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET)
    if(_rc EQUAL 0 AND _has STREQUAL "yes")
        set(HAVE_${_FEATURE} ON)
    else()
        set(HAVE_${_FEATURE} OFF)
    endif()
    message(STATUS "netCDF-C ${_feature} support: ${HAVE_${_FEATURE}}")
endforeach()

set(_ld_dirs ${NC_LIBDIR})
if(HDF5_PREFIX)
    list(APPEND _ld_dirs ${HDF5_PREFIX}/lib)
endif()

# Fortran examples are built when nf-config can be found; set
# -DENABLE_FORTRAN=OFF to skip them, or NETCDF_FORTRAN_PREFIX to point at a
# netcdf-fortran install that is not on PATH.
set(HAVE_NETCDF_FORTRAN OFF)
if(ENABLE_FORTRAN)
    set(_nf_config_hints "")
    if(NETCDF_FORTRAN_PREFIX)
        list(APPEND _nf_config_hints ${NETCDF_FORTRAN_PREFIX}/bin)
    endif()
    list(APPEND _nf_config_hints ${_nc_config_hints})
    find_program(NF_CONFIG nf-config HINTS ${_nf_config_hints})
    if(NF_CONFIG)
        enable_language(Fortran)
        execute_process(COMMAND ${NF_CONFIG} --version OUTPUT_VARIABLE NF_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)
        execute_process(COMMAND ${NF_CONFIG} --fflags OUTPUT_VARIABLE NF_FFLAGS OUTPUT_STRIP_TRAILING_WHITESPACE)
        execute_process(COMMAND ${NF_CONFIG} --flibs OUTPUT_VARIABLE NF_LIBS OUTPUT_STRIP_TRAILING_WHITESPACE)
        execute_process(COMMAND ${NF_CONFIG} --prefix OUTPUT_VARIABLE NF_PREFIX OUTPUT_STRIP_TRAILING_WHITESPACE)
        message(STATUS "Using ${NF_VERSION} from ${NF_CONFIG}")
        separate_arguments(NF_FFLAGS_LIST UNIX_COMMAND "${NF_FFLAGS}")
        separate_arguments(NF_LIBS_LIST UNIX_COMMAND "${NF_LIBS}")
        list(APPEND _ld_dirs ${NF_PREFIX}/lib)
        set(HAVE_NETCDF_FORTRAN ON)

        # netcdf-fortran only exposes nf90_def_var_zstandard when it was built
        # against a netCDF-C with zstd support (e.g. Ubuntu's apt build lacks it).
        include(CheckFortranSourceCompiles)
        set(CMAKE_REQUIRED_FLAGS "${NF_FFLAGS}")
        set(CMAKE_REQUIRED_LIBRARIES ${NF_LIBS_LIST} ${NC_LIBS_LIST})
        check_fortran_source_compiles("
program probe
  use netcdf
  integer :: ncid, varid, ret
  ret = nf90_def_var_zstandard(ncid, varid, 3)
end program probe
" HAVE_NF90_ZSTANDARD SRC_EXT f90)
        unset(CMAKE_REQUIRED_FLAGS)
        unset(CMAKE_REQUIRED_LIBRARIES)
    else()
        message(STATUS "nf-config not found; Fortran examples will not be built "
                       "(set NETCDF_FORTRAN_PREFIX or -DENABLE_FORTRAN=OFF to silence this)")
    endif()
endif()

list(JOIN _ld_dirs ":" _ld_path)
set(NC_TEST_ENV "LD_LIBRARY_PATH=${_ld_path}:$ENV{LD_LIBRARY_PATH}")

# Point the tests at netCDF-C's filter plugins (needed for compression in
# NcZarr and for the bzip2/lz4/zstandard performance examples) unless the
# caller already set HDF5_PLUGIN_PATH.
if(NOT DEFINED ENV{HDF5_PLUGIN_PATH})
    execute_process(COMMAND ${NC_CONFIG} --plugindir
                    OUTPUT_VARIABLE NC_PLUGINDIR RESULT_VARIABLE _rc
                    OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET)
    if(_rc EQUAL 0 AND IS_DIRECTORY "${NC_PLUGINDIR}")
        message(STATUS "Using netCDF filter plugins from ${NC_PLUGINDIR}")
        list(APPEND NC_TEST_ENV "HDF5_PLUGIN_PATH=${NC_PLUGINDIR}")
    endif()
endif()

# Build one example program from <name>.c in the current directory.
function(add_netcdf_example name)
    add_executable(${name} ${name}.c)
    target_compile_options(${name} PRIVATE ${NC_CFLAGS_LIST})
    if(HDF5_PREFIX)
        target_link_directories(${name} PRIVATE ${HDF5_PREFIX}/lib)
    endif()
    target_link_libraries(${name} PRIVATE ${NC_LIBS_LIST} m)
endfunction()

# Build one example program from <name>.f90 in the current directory.
function(add_netcdf_fortran_example name)
    add_executable(${name} ${name}.f90)
    set_target_properties(${name} PROPERTIES Fortran_PREPROCESS ON)
    target_compile_options(${name} PRIVATE ${NF_FFLAGS_LIST})
    if(HAVE_NF90_ZSTANDARD)
        target_compile_definitions(${name} PRIVATE HAVE_NF90_ZSTANDARD)
    endif()
    if(HDF5_PREFIX)
        target_link_directories(${name} PRIVATE ${HDF5_PREFIX}/lib)
    endif()
    target_link_libraries(${name} PRIVATE ${NF_LIBS_LIST} ${NC_LIBS_LIST})
endfunction()

# Register a ctest that runs the given command line in the current binary dir.
function(add_netcdf_run name)
    add_test(NAME ${name} COMMAND ${ARGN} WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
    set_tests_properties(${name} PROPERTIES ENVIRONMENT "${NC_TEST_ENV}")
endfunction()
