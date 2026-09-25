add_subdirectory(classic)
add_subdirectory(netcdf-4)
add_subdirectory(performance)

if(HAVE_NETCDF_FORTRAN)
    add_subdirectory(f_classic)
    add_subdirectory(f_netcdf-4)
endif()
