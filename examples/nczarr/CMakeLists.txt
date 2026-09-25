# NcZarr examples: write and read back file://*.zarr#mode=nczarr stores in
# the build directory. Requires a netCDF-C built with NcZarr.

set(NCZARR_EXAMPLES
    nczarr_simple
    nczarr_chunking
    nczarr_compression
    nczarr_enhanced
)

foreach(example ${NCZARR_EXAMPLES})
    add_netcdf_example(${example})
    add_netcdf_run(${example} ${example})
endforeach()

if(HAVE_NETCDF_FORTRAN)
    foreach(example ${NCZARR_EXAMPLES})
        add_netcdf_fortran_example(f_${example})
        add_netcdf_run(f_${example} f_${example})
    endforeach()
endif()
