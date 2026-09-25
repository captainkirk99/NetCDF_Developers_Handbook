# Performance examples: chunking, caching, compression filters, fill values,
# endianness. The bzip2, lz4 and zstandard programs need the matching HDF5
# filter plugin (HDF5_PLUGIN_PATH) and exit successfully with a "skipping"
# message when it is not installed.

set(PERFORMANCE_EXAMPLES
    cache_tuning
    chunking
    deflate
    endianness
    fill_values
    szip
    zstandard
    bzip2
    lz4
)

foreach(example ${PERFORMANCE_EXAMPLES})
    add_netcdf_example(${example})
    add_netcdf_run(${example} ${example})
endforeach()

# cache_tuning only runs its timing sweeps when built with ENABLE_BENCHMARKS.
option(ENABLE_BENCHMARKS "Build cache_tuning with its timing benchmarks enabled" OFF)
if(ENABLE_BENCHMARKS)
    target_compile_definitions(cache_tuning PRIVATE ENABLE_BENCHMARKS=1)
endif()

# Each program writes a ~130 MB scratch file; do not run them concurrently.
set_tests_properties(${PERFORMANCE_EXAMPLES} PROPERTIES RUN_SERIAL TRUE)
