\mainpage The NetCDF Developer's Handbook

<a href="https://www.amazon.com/NetCDF-Developers-Handbook-Authoritative-High-Performance/dp/B0GYP4R5ZZ/">
<img src="netcdf_developers_handbook_cover.jpg" alt="The NetCDF Developer's Handbook cover" width="220" align="right" hspace="16">
</a>

**The NetCDF Developer's Handbook: The Authoritative Guide to Writing
High-Performance Programs for Scientific Data Management**, by Edward
Hartnett, is a practical guide to programming with netCDF in C and Fortran:
the classic and enhanced data models, chunking and compression, performance
tuning, NcZarr cloud storage, OPeNDAP remote access and parallel I/O. It is
[available on Amazon](https://www.amazon.com/NetCDF-Developers-Handbook-Authoritative-High-Performance/dp/B0GYP4R5ZZ/).

These pages document the book's example programs, which live in the
[NetCDF_Developers_Handbook](https://github.com/captainkirk99/NetCDF_Developers_Handbook)
repository. Every program is self-contained: it creates (and usually reads
back) its own data, prints what it did and exits 0 on success. Each C example
has a Fortran twin with an `f_` prefix that produces the same file. Click an
example name to open its documentation and source code.

```
cmake -S . -B build
cmake --build build
ctest --test-dir build
```

See the [release notes](@ref md_docs_release_notes_v1_0), the
[roadmap](@ref md_docs_roadmap) and the
[list of files moved from NEP](@ref md_docs_nep_handoff).

<br clear="all">

## Classic data model

Files in the classic (CDF-1/2/5) formats: dimensions, variables,
attributes, coordinate variables and the unlimited dimension.

| C | Fortran | Demonstrates |
|---|---|---|
| [quickstart.c](@ref classic/quickstart.c) | [f_quickstart.f90](@ref f_classic/f_quickstart.f90) | The smallest complete netCDF program: create, define, write, close, reopen, read |
| [simple_2D.c](@ref classic/simple_2D.c) | [f_simple_2D.f90](@ref f_classic/f_simple_2D.f90) | Writing and reading a 2D integer array |
| [var4d.c](@ref classic/var4d.c) | [f_var4d.f90](@ref f_classic/f_var4d.f90) | 2D, 3D and 4D variables sharing dimensions |
| [coord.c](@ref classic/coord.c) | [f_coord.f90](@ref f_classic/f_coord.f90) | 3D surface temperature with `time`, `lat`, `lon` coordinate variables |
| [coord_vars.c](@ref classic/coord_vars.c) | [f_coord_vars.f90](@ref f_classic/f_coord_vars.f90) | Coordinate variables and CF-convention attributes (`units`, `long_name`, `axis`) |
| [unlimited_dim.c](@ref classic/unlimited_dim.c) | [f_unlimited_dim.f90](@ref f_classic/f_unlimited_dim.f90) | Appending records along an unlimited dimension |
| [size_limits.c](@ref classic/size_limits.c) | [f_size_limits.f90](@ref f_classic/f_size_limits.f90) | The size limits of CDF-1, CDF-2 (64-bit offset) and CDF-5 |
| [dump_classic_metadata.c](@ref classic/dump_classic_metadata.c) | [f_dump_classic_metadata.f90](@ref f_classic/f_dump_classic_metadata.f90) | Reading back every dimension, variable and attribute of a file (runs on `coord_vars.nc`) |

## Enhanced data model

netCDF-4/HDF5 features: groups, user-defined types, multiple unlimited
dimensions, chunking and compression.

| C | Fortran | Demonstrates |
|---|---|---|
| [simple_nc4.c](@ref netcdf-4/simple_nc4.c) | [f_simple_nc4.f90](@ref f_netcdf-4/f_simple_nc4.f90) | Creating a netCDF-4/HDF5 file and detecting its format |
| [format_variants.c](@ref netcdf-4/format_variants.c) | [f_format_variants.f90](@ref f_netcdf-4/f_format_variants.f90) | All five on-disk formats (CDF-1, CDF-2, CDF-5, netCDF-4, netCDF-4 classic model) |
| [groups.c](@ref netcdf-4/groups.c) | [f_groups.f90](@ref f_netcdf-4/f_groups.f90) | Hierarchical groups, nested groups and dimension visibility across groups |
| [user_types.c](@ref netcdf-4/user_types.c) | [f_user_types.f90](@ref f_netcdf-4/f_user_types.f90) | Compound, enum, variable-length and opaque types |
| [multi_unlimited.c](@ref netcdf-4/multi_unlimited.c) | [f_multi_unlimited.f90](@ref f_netcdf-4/f_multi_unlimited.f90) | Several unlimited dimensions in one file |
| [chunking_performance.c](@ref netcdf-4/chunking_performance.c) | [f_chunking_performance.f90](@ref f_netcdf-4/f_chunking_performance.f90) | How chunk shape affects read and write time for different access patterns |
| [compression.c](@ref netcdf-4/compression.c) | [f_compression.f90](@ref f_netcdf-4/f_compression.f90) | Deflate, shuffle and zstandard, alone and combined, with size and timing comparison |
| [dump_nc4_metadata.c](@ref netcdf-4/dump_nc4_metadata.c) | [f_dump_nc4_metadata.f90](@ref f_netcdf-4/f_dump_nc4_metadata.f90) | Reading back groups, user-defined types and attributes (runs on `user_types.nc`) |

## Performance

Each program writes a 500x180x360 float field with a sweep of settings and
prints a CSV table of file size, write time and read time.


The three plugin-based programs print a "skipping" message and exit 0 when
the plugin is not installed.

| C | Demonstrates |
|---|---|
| [chunking.c](@ref performance/chunking.c) | Chunk shape versus I/O pattern |
| [cache_tuning.c](@ref performance/cache_tuning.c) | The per-variable chunk cache (`nc_set_var_chunk_cache`); full sweep only with `-DENABLE_BENCHMARKS=ON` |
| [fill_values.c](@ref performance/fill_values.c) | Cost of fill values in classic and netCDF-4 files |
| [endianness.c](@ref performance/endianness.c) | Little- versus big-endian storage (`nc_def_var_endian`) |
| [deflate.c](@ref performance/deflate.c) | zlib deflate levels with and without the shuffle filter |
| [szip.c](@ref performance/szip.c) | SZIP `options_mask` and `pixels_per_block` |
| [bzip2.c](@ref performance/bzip2.c) | BZIP2 levels with and without shuffle (needs the bzip2 filter plugin) |
| [lz4.c](@ref performance/lz4.c) | LZ4 levels with and without shuffle (needs the lz4 filter plugin) |
| [zstandard.c](@ref performance/zstandard.c) | Zstandard levels with and without shuffle (needs the zstd filter plugin) |

## NcZarr

The same API writing Zarr directory stores (`file://name.zarr#mode=nczarr`)
instead of HDF5 files. Built when `nc-config --has-nczarr` is `yes`.

| C | Fortran | Demonstrates |
|---|---|---|
| [nczarr_simple.c](@ref nczarr/nczarr_simple.c) | [f_nczarr_simple.f90](@ref nczarr/f_nczarr_simple.f90) | Create, write, read a local NcZarr store |
| [nczarr_chunking.c](@ref nczarr/nczarr_chunking.c) | [f_nczarr_chunking.f90](@ref nczarr/f_nczarr_chunking.f90) | Explicit chunk shape, which decides how the data is split into files in the Zarr directory tree |
| [nczarr_compression.c](@ref nczarr/nczarr_compression.c) | [f_nczarr_compression.f90](@ref nczarr/f_nczarr_compression.f90) | Shuffle and deflate in NcZarr (needs the deflate filter plugin) |
| [nczarr_enhanced.c](@ref nczarr/nczarr_enhanced.c) | [f_nczarr_enhanced.f90](@ref nczarr/f_nczarr_enhanced.f90) | Groups and unlimited dimensions in NcZarr |

## OPeNDAP

Reading a remote dataset (`http://test.opendap.org/dap/data/nc/sst.mnmean.nc.gz`)
through the DAP client built into netCDF-C. Built when `nc-config --has-dap`
is `yes`; needs network access, so run only with `-DRUN_OPENDAP_EXAMPLES=ON`.

| C | Fortran | Demonstrates |
|---|---|---|
| [opendap_simple.c](@ref opendap/opendap_simple.c) | [f_opendap_simple.f90](@ref opendap/f_opendap_simple.f90) | Opening a URL like a file and reading metadata and data |
| [opendap_constraint.c](@ref opendap/opendap_constraint.c) | [f_opendap_constraint.f90](@ref opendap/f_opendap_constraint.f90) | Server-side subsetting with a DAP constraint expression in the URL |
| [opendap_subset.c](@ref opendap/opendap_subset.c) | [f_opendap_subset.f90](@ref opendap/f_opendap_subset.f90) | Client-side subsetting with `start`/`count` on a remote variable |

## Parallel I/O

Collective writes to one netCDF-4 file from several MPI ranks. Built with
`-DENABLE_PARALLEL=ON`; needs MPI and a parallel netCDF-C.

| C | Fortran | Demonstrates |
|---|---|---|
| [square16_par.c](@ref parallelIO/square16_par.c) | [f_square16_par.f90](@ref parallelIO/f_square16_par.f90) | A 16x16 array written by 4 ranks in a 2x2 decomposition (`nc_create_par`, `nc_var_par_access`); run with `mpiexec -n 4` |

## See also

For more netCDF examples, see the author's other book,
[*Earth Observation in Practice: A Mission-by-Mission Guide to Reading
Satellite Data with NetCDF and Python*](https://www.amazon.com/Earth-Observation-Practice-Mission-Mission/dp/B0HJRZ9F7L/),
which has its own example repository at
[captainkirk99/Earth_Observation_in_Practice](https://github.com/captainkirk99/Earth_Observation_in_Practice).
