# Fortran versions of the netCDF-4 examples.

set(F_NETCDF4_EXAMPLES
    f_simple_nc4
    f_groups
    f_compression
    f_chunking_performance
    f_user_types
    f_multi_unlimited
    f_format_variants
)

foreach(example ${F_NETCDF4_EXAMPLES})
    add_netcdf_fortran_example(${example})
    add_netcdf_run(${example} ${example})
endforeach()

# f_dump_nc4_metadata takes a file name; use the one written by f_user_types.
add_netcdf_fortran_example(f_dump_nc4_metadata)
add_netcdf_run(f_dump_nc4_metadata f_dump_nc4_metadata f_user_types.nc)
set_tests_properties(f_dump_nc4_metadata PROPERTIES DEPENDS f_user_types)
