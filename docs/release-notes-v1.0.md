# Release notes - v1.0

First release of the example programs for *The NetCDF Developer's Handbook*
by Edward Hartnett. Everything here was moved from the
[NetCDF Expansion Pack](https://github.com/Intelligent-Data-Design-Inc/NEP)
so that the pure-netCDF examples live in a repository of their own; see
[nep-handoff.md](nep-handoff.md) for the file-by-file list.

## What is in this release

57 standalone programs, each of which creates its own data, runs without
arguments and exits 0 on success. C and Fortran versions are provided for
everything except the performance benchmarks.

| Directory | C | Fortran | Topic |
|---|---|---|---|
| `examples/classic`, `examples/f_classic` | 8 | 8 | Classic data model: dimensions, variables, attributes, coordinate variables, unlimited dimension, CDF-1/2/5 size limits |
| `examples/netcdf-4`, `examples/f_netcdf-4` | 8 | 8 | Enhanced data model: groups, user-defined types, multiple unlimited dimensions, chunking, compression, all five file formats |
| `examples/performance` | 9 | - | Chunking, chunk cache, fill values, endianness, deflate, szip, bzip2, lz4, zstandard benchmarks |
| `examples/nczarr` | 4 | 4 | Zarr directory stores through the netCDF API |
| `examples/opendap` | 3 | 3 | Reading a remote dataset through the DAP client |
| `examples/parallelIO` | 1 | 1 | Collective netCDF-4 I/O from four MPI ranks |

[examples/README.md](../examples/README.md) describes every program.

## Building and running

- CMake (3.18 or newer) build driven by `nc-config` and `nf-config`, so the
  same tree builds against a source install (`-DNETCDF_PREFIX=...`) or
  distribution packages.
- `ctest` runs every program directly; there is no test framework and no
  mocked data.
- Optional components are detected or opted in:
  - Fortran examples when `nf-config` is found (`ENABLE_FORTRAN`, default on).
  - NcZarr examples when `nc-config --has-nczarr` is `yes`.
  - OPeNDAP examples are built when `nc-config --has-dap` is `yes` and run
    only with `-DRUN_OPENDAP_EXAMPLES=ON` (network access).
  - Parallel I/O with `-DENABLE_PARALLEL=ON` (MPI and a parallel netCDF-C).
- Compression examples that need an HDF5 filter plugin (bzip2, lz4,
  zstandard, NcZarr deflate) report "skipping" and succeed when the plugin is
  not installed, so the suite passes on a stock distribution install.

## Continuous integration and documentation

- GitHub Actions builds and runs the examples on Ubuntu with the apt netCDF,
  netCDF-Fortran and HDF5 packages, plus a second job for the parallel I/O
  examples with Open MPI.
- Doxygen documentation for every source file is built on each push and
  published at <https://captainkirk99.github.io/NetCDF_Developers_Handbook/>.

## Changes relative to the NEP sources

Nine files were adapted so they run on the netCDF packages shipped by Ubuntu:

- `netcdf-4/compression.c`, `f_netcdf-4/f_compression.f90`: zstandard is
  probed with a write/reopen/read round trip (C) or guarded by
  `HAVE_NF90_ZSTANDARD` (Fortran) because the library can accept the call
  without having the filter.
- `performance/bzip2.c`, `lz4.c`, `zstandard.c`: skip when the filter plugin
  cannot be loaded.
- `nczarr/nczarr_compression.c`, `f_nczarr_compression.f90`: skip when
  NcZarr filter support is absent (`NC_ENOFILTER`, or filters silently
  dropped).
- `nczarr/nczarr_enhanced.c`, `f_nczarr_enhanced.f90`: fall back to a fixed
  dimension when the NcZarr build rejects unlimited dimensions
  (`NC_EDIMSIZE`).

## Not included

NEP examples that depend on the Expansion Pack (`performance/lossless.c`,
`performance/quantize.c`, `pdb`, `dicom`, `viz`), NEP's expected-output test
harness, and the benchmark result files and plotting scripts.
