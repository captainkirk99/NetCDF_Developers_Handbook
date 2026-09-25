# Locate nc-config and provide add_netcdf_example()/add_netcdf_run() helpers
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

set(_ld_dirs ${NC_LIBDIR})
if(HDF5_PREFIX)
    list(APPEND _ld_dirs ${HDF5_PREFIX}/lib)
endif()
list(JOIN _ld_dirs ":" _ld_path)
set(NC_TEST_ENV "LD_LIBRARY_PATH=${_ld_path}:$ENV{LD_LIBRARY_PATH}")

# Build one example program from <name>.c in the current directory.
function(add_netcdf_example name)
    add_executable(${name} ${name}.c)
    target_compile_options(${name} PRIVATE ${NC_CFLAGS_LIST})
    if(HDF5_PREFIX)
        target_link_directories(${name} PRIVATE ${HDF5_PREFIX}/lib)
    endif()
    target_link_libraries(${name} PRIVATE ${NC_LIBS_LIST} m)
endfunction()

# Register a ctest that runs the given command line in the current binary dir.
function(add_netcdf_run name)
    add_test(NAME ${name} COMMAND ${ARGN} WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
    set_tests_properties(${name} PROPERTIES ENVIRONMENT "${NC_TEST_ENV}")
endfunction()
