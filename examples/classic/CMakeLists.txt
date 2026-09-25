# Classic-model netCDF examples (C)

set(CLASSIC_EXAMPLES
    quickstart
    simple_2D
    coord
    coord_vars
    var4d
    unlimited_dim
    size_limits
)

foreach(example ${CLASSIC_EXAMPLES})
    add_netcdf_example(${example})
    add_netcdf_run(${example} ${example})
endforeach()

# dump_classic_metadata takes a file argument; use the file written by coord_vars.
add_netcdf_example(dump_classic_metadata)
add_netcdf_run(dump_classic_metadata dump_classic_metadata coord_vars.nc)
set_tests_properties(dump_classic_metadata PROPERTIES DEPENDS coord_vars)
