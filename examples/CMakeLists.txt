add_subdirectory(classic)
add_subdirectory(netcdf-4)
add_subdirectory(performance)

if(HAVE_NETCDF_FORTRAN)
    add_subdirectory(f_classic)
    add_subdirectory(f_netcdf-4)
endif()

if(HAVE_NCZARR)
    add_subdirectory(nczarr)
else()
    message(STATUS "netCDF-C built without NcZarr; skipping examples/nczarr")
endif()

if(HAVE_DAP)
    add_subdirectory(opendap)
else()
    message(STATUS "netCDF-C built without DAP; skipping examples/opendap")
endif()

if(ENABLE_PARALLEL)
    add_subdirectory(parallelIO)
endif()
