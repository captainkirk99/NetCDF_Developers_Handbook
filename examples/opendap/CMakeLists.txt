# OPeNDAP examples: read a remote dataset from test.opendap.org. Requires a
# netCDF-C built with DAP. They are built by default but only registered
# with ctest when RUN_OPENDAP_EXAMPLES is ON, since they need network access.

set(OPENDAP_EXAMPLES
    opendap_simple
    opendap_constraint
    opendap_subset
)

foreach(example ${OPENDAP_EXAMPLES})
    add_netcdf_example(${example})
    if(RUN_OPENDAP_EXAMPLES)
        add_netcdf_run(${example} ${example})
    endif()
endforeach()

if(HAVE_NETCDF_FORTRAN)
    foreach(example ${OPENDAP_EXAMPLES})
        add_netcdf_fortran_example(f_${example})
        if(RUN_OPENDAP_EXAMPLES)
            add_netcdf_run(f_${example} f_${example})
        endif()
    endforeach()
endif()
