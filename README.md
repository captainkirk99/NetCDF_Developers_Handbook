# The NetCDF Developer's Handbook

[![CI](https://github.com/captainkirk99/NetCDF_Developers_Handbook/actions/workflows/ci.yml/badge.svg)](https://github.com/captainkirk99/NetCDF_Developers_Handbook/actions/workflows/ci.yml)

Example programs for the book by Edward Hartnett:

<p align="center">
  <a href="https://www.amazon.com/NetCDF-Developers-Handbook-Authoritative-High-Performance/dp/B0GYP4R5ZZ/">
    <img src="docs/images/netcdf_developers_handbook_cover.jpg" alt="The NetCDF Developer's Handbook cover" width="300">
  </a>
  <br>
  <a href="https://www.amazon.com/NetCDF-Developers-Handbook-Authoritative-High-Performance/dp/B0GYP4R5ZZ/"><b>The NetCDF Developer's Handbook</b></a>
  <br>
  The Authoritative Guide to Writing High-Performance Programs for Scientific Data Management
</p>

## What is here

The `examples/` directory contains the complete, working C and Fortran
programs discussed in *The NetCDF Developer's Handbook*: classic-model and
netCDF-4 files, groups, user-defined types, compression and chunking,
performance tuning, NcZarr, OPeNDAP and parallel I/O. Each example is a small
standalone program that writes (and usually reads back) a netCDF file, so it
can be run directly to see the concepts from the book in action.

The examples are being moved here from the
[NetCDF Expansion Pack](https://github.com/Intelligent-Data-Design-Inc/NEP);
see [docs/roadmap.md](docs/roadmap.md) for the plan and current status.

## See also: Earth Observation in Practice

<a href="https://www.amazon.com/Earth-Observation-Practice-Mission-Mission/dp/B0HJRZ9F7L/">
  <img src="docs/images/earth_observation_in_practice_cover.jpg" alt="Earth Observation in Practice cover" width="150" align="left" hspace="12">
</a>

For more netCDF examples, see my other book,
[*Earth Observation in Practice: A Mission-by-Mission Guide to Reading Satellite Data with NetCDF and Python*](https://www.amazon.com/Earth-Observation-Practice-Mission-Mission/dp/B0HJRZ9F7L/).
It reads real satellite data products with netCDF and Python, and has its own
example repository at
[captainkirk99/Earth_Observation_in_Practice](https://github.com/captainkirk99/Earth_Observation_in_Practice).
The examples in this repository are not related to that book.

<br clear="all">

## Building and running the examples

Requirements: CMake 3.16 or later, a C compiler, and netCDF-C (with HDF5)
installed so that `nc-config` can be found. For the Fortran examples you also
need a Fortran compiler and netCDF-Fortran (`nf-config`).

```sh
cmake -S . -B build -DNETCDF_PREFIX=/usr/local/netcdf-c -DHDF5_PREFIX=/usr/local/hdf5-2.1.1 \
      -DNETCDF_FORTRAN_PREFIX=/usr/local/netcdf-fortran
cmake --build build
ctest --test-dir build --output-on-failure
```

Omit `NETCDF_PREFIX` and `HDF5_PREFIX` if `nc-config` is already on your
`PATH` (for example when netCDF is installed from your distribution's
packages). `ctest` runs every example that does not need an external data
file.

The Fortran examples (`examples/f_classic`, `examples/f_netcdf-4`) are built
whenever `nf-config` is found, next to `nc-config` or under
`NETCDF_FORTRAN_PREFIX`; otherwise they are skipped with a status message.
Pass `-DENABLE_FORTRAN=OFF` to leave them out entirely.

The `examples/performance` programs `bzip2`, `lz4` and `zstandard` need the
matching HDF5 filter plugin. They build everywhere but print a "skipping"
message and exit successfully when the plugin cannot be loaded. To run them,
install the plugins (for example from the
[netcdf-c](https://github.com/Unidata/netcdf-c) `plugins/` directory, or the
[HDF5 filter plugins](https://github.com/HDFGroup/hdf5_plugins)) and point
`HDF5_PLUGIN_PATH` at the directory containing them before running `ctest`.
`cache_tuning` runs its timing sweeps only when configured with
`-DENABLE_BENCHMARKS=ON`.

## License

See [LICENSE](LICENSE).
