# Fortran versions of the classic-model examples.

set(F_CLASSIC_EXAMPLES
    f_quickstart
    f_simple_2D
    f_coord
    f_coord_vars
    f_var4d
    f_unlimited_dim
    f_size_limits
)

foreach(example ${F_CLASSIC_EXAMPLES})
    add_netcdf_fortran_example(${example})
    add_netcdf_run(${example} ${example})
endforeach()

# f_dump_classic_metadata takes a file name; use the one written by f_coord_vars.
add_netcdf_fortran_example(f_dump_classic_metadata)
add_netcdf_run(f_dump_classic_metadata f_dump_classic_metadata f_coord_vars.nc)
set_tests_properties(f_dump_classic_metadata PROPERTIES DEPENDS f_coord_vars)
