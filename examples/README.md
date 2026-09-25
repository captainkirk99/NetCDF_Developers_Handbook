# Examples

Companion programs for *The NetCDF Developer's Handbook*. Every program is
self-contained: it creates (and usually reads back) its own data, prints
what it did, and exits 0 on success, so it can be run directly after
building. See the [top-level README](../README.md) for build instructions.

```sh
cmake -S . -B build            # from the repository root
cmake --build build
ctest --test-dir build         # run everything that needs no external data
./build/examples/classic/quickstart   # or run one program by hand
```

Each C program has a Fortran twin with an `f_` prefix (`quickstart.c` and
`f_quickstart.f90`) that produces the same file. The Fortran examples are
built when `nf-config` is found.

## Classic data model (`classic/`, `f_classic/`)

Files in the classic (CDF-1/2/5) formats: dimensions, variables,
attributes, coordinate variables and the unlimited dimension.

| Program | Demonstrates |
|---|---|
| `quickstart` | The smallest complete netCDF program: create, define, write, close, reopen, read |
| `simple_2D` | Writing and reading a 2D integer array |
| `var4d` | 2D, 3D and 4D variables sharing dimensions |
| `coord` | 3D surface temperature with `time`, `lat`, `lon` coordinate variables |
| `coord_vars` | Coordinate variables and CF-convention attributes (`units`, `long_name`, `axis`) |
| `unlimited_dim` | Appending records along an unlimited dimension |
| `size_limits` | The size limits of CDF-1, CDF-2 (64-bit offset) and CDF-5 |
| `dump_classic_metadata` | Reading back every dimension, variable and attribute of a file (runs on `coord_vars.nc`) |

## Enhanced data model (`netcdf-4/`, `f_netcdf-4/`)

netCDF-4/HDF5 features: groups, user-defined types, multiple unlimited
dimensions, chunking and compression.

| Program | Demonstrates |
|---|---|
| `simple_nc4` | Creating a netCDF-4/HDF5 file and detecting its format |
| `format_variants` | All five on-disk formats (CDF-1, CDF-2, CDF-5, netCDF-4, netCDF-4 classic model) |
| `groups` | Hierarchical groups, nested groups and dimension visibility across groups |
| `user_types` | Compound, enum, variable-length and opaque types |
| `multi_unlimited` | Several unlimited dimensions in one file |
| `chunking_performance` | How chunk shape affects read and write time for different access patterns |
| `compression` | Deflate, shuffle and zstandard, alone and combined, with size and timing comparison |
| `dump_nc4_metadata` | Reading back groups, user-defined types and attributes (runs on `user_types.nc`) |

## Performance (`performance/`, C only)

Each program writes a 500x180x360 float field with a sweep of settings and
prints a CSV table of file size, write time and read time.

| Program | Demonstrates |
|---|---|
| `chunking` | Chunk shape versus I/O pattern |
| `cache_tuning` | The per-variable chunk cache (`nc_set_var_chunk_cache`); full sweep only with `-DENABLE_BENCHMARKS=ON` |
| `fill_values` | Cost of fill values in classic and netCDF-4 files |
| `endianness` | Little- versus big-endian storage (`nc_def_var_endian`) |
| `deflate` | zlib deflate levels with and without the shuffle filter |
| `szip` | SZIP `options_mask` and `pixels_per_block` |
| `bzip2` | BZIP2 levels with and without shuffle (needs the bzip2 filter plugin) |
| `lz4` | LZ4 levels with and without shuffle (needs the lz4 filter plugin) |
| `zstandard` | Zstandard levels with and without shuffle (needs the zstd filter plugin) |

The three plugin-based programs print a "skipping" message and exit 0 when
the plugin is not installed.

## NcZarr (`nczarr/`)

The same API writing Zarr directory stores (`file://name.zarr#mode=nczarr`)
instead of HDF5 files. Built when `nc-config --has-nczarr` is `yes`.

| Program | Demonstrates |
|---|---|
| `nczarr_simple` | Create, write, read a local NcZarr store |
| `nczarr_chunking` | Explicit chunk shape, which decides how the data is split into files in the Zarr directory tree |
| `nczarr_compression` | Shuffle and deflate in NcZarr (needs the deflate filter plugin) |
| `nczarr_enhanced` | Groups and unlimited dimensions in NcZarr |

## OPeNDAP (`opendap/`)

Reading a remote dataset (`http://test.opendap.org/dap/data/nc/sst.mnmean.nc.gz`)
through the DAP client built into netCDF-C. Built when `nc-config --has-dap`
is `yes`; needs network access, so run only with `-DRUN_OPENDAP_EXAMPLES=ON`.

| Program | Demonstrates |
|---|---|
| `opendap_simple` | Opening a URL like a file and reading metadata and data |
| `opendap_constraint` | Server-side subsetting with a DAP constraint expression in the URL |
| `opendap_subset` | Client-side subsetting with `start`/`count` on a remote variable |

## Parallel I/O (`parallelIO/`)

Collective writes to one netCDF-4 file from several MPI ranks. Built with
`-DENABLE_PARALLEL=ON`; needs MPI and a parallel netCDF-C.

| Program | Demonstrates |
|---|---|
| `square16_par` | A 16x16 array written by 4 ranks in a 2x2 decomposition (`nc_create_par`, `nc_var_par_access`); run with `mpiexec -n 4` |
