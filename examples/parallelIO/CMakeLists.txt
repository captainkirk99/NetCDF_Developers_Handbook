# Parallel I/O examples (ENABLE_PARALLEL=ON). Both programs must be run on
# exactly 4 MPI ranks.
#
# The C example needs a netCDF-C built with parallel support, located with
# pkg-config. NETCDF_PARALLEL_PKG names the module: the default "netcdf-mpi"
# is what Ubuntu's libnetcdf-mpi-dev installs; use "netcdf" (with
# PKG_CONFIG_PATH pointing at its lib/pkgconfig) for a self-built parallel
# netCDF-C. netcdf_par.h is looked up separately because Ubuntu's .pc file
# points at the serial headers.

find_package(MPI REQUIRED COMPONENTS C)
find_package(PkgConfig REQUIRED)
pkg_check_modules(NETCDF_PAR REQUIRED ${NETCDF_PARALLEL_PKG})
find_path(NETCDF_PAR_INCLUDE_DIR netcdf_par.h
          HINTS ${NETCDF_PAR_INCLUDE_DIRS} ${NETCDF_PAR_PREFIX}/include
                ${NETCDF_PAR_LIBDIR}/netcdf/mpi/include)
if(NOT NETCDF_PAR_INCLUDE_DIR)
    message(FATAL_ERROR "netcdf_par.h not found; is ${NETCDF_PARALLEL_PKG} a parallel netCDF-C?")
endif()
message(STATUS "Parallel netCDF-C: ${NETCDF_PAR_VERSION} (pkg-config ${NETCDF_PARALLEL_PKG}), "
               "headers in ${NETCDF_PAR_INCLUDE_DIR}")

# Open MPI refuses to start more ranks than cores unless told to oversubscribe
# (CI runners have 2); other MPIs ignore the OMPI_* variable.
set(_mpi_flags -n 4)
set(_mpi_env OMPI_MCA_rmaps_base_oversubscribe=1)

add_executable(square16_par square16_par.c)
target_include_directories(square16_par PRIVATE ${NETCDF_PAR_INCLUDE_DIR} ${NETCDF_PAR_INCLUDE_DIRS})
target_compile_options(square16_par PRIVATE ${NETCDF_PAR_CFLAGS_OTHER})
target_link_directories(square16_par PRIVATE ${NETCDF_PAR_LIBRARY_DIRS})
target_link_libraries(square16_par PRIVATE ${NETCDF_PAR_LIBRARIES} MPI::MPI_C)
add_netcdf_run(square16_par ${MPIEXEC_EXECUTABLE} ${_mpi_flags} $<TARGET_FILE:square16_par>)
set_property(TEST square16_par APPEND PROPERTY ENVIRONMENT ${_mpi_env})

if(HAVE_NETCDF_FORTRAN)
    find_package(MPI REQUIRED COMPONENTS Fortran)
    add_netcdf_fortran_example(f_square16_par)
    target_link_libraries(f_square16_par PRIVATE MPI::MPI_Fortran)
    if(NETCDF_FORTRAN_PARALLEL)
        add_netcdf_run(f_square16_par ${MPIEXEC_EXECUTABLE} ${_mpi_flags} $<TARGET_FILE:f_square16_par>)
        set_property(TEST f_square16_par APPEND PROPERTY ENVIRONMENT ${_mpi_env})
    else()
        message(STATUS "f_square16_par built but not run (set NETCDF_FORTRAN_PARALLEL=ON "
                       "if netCDF-Fortran links a parallel netCDF-C)")
    endif()
endif()
