# netCDF-4 (enhanced model) examples (C)

set(NETCDF4_EXAMPLES
    simple_nc4
    groups
    compression
    chunking_performance
    user_types
    multi_unlimited
    format_variants
)

foreach(example ${NETCDF4_EXAMPLES})
    add_netcdf_example(${example})
    add_netcdf_run(${example} ${example})
endforeach()

# dump_nc4_metadata takes a file argument; use the file written by user_types.
add_netcdf_example(dump_nc4_metadata)
add_netcdf_run(dump_nc4_metadata dump_nc4_metadata user_types.nc)
set_tests_properties(dump_nc4_metadata PROPERTIES DEPENDS user_types)
