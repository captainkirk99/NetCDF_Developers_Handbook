# Files moved from NEP

Version 1.0 of this repository holds copies of the pure-netCDF examples from
the [NetCDF Expansion Pack](https://github.com/Intelligent-Data-Design-Inc/NEP)
(`examples/` there). NEP was not modified; this list is the handoff for
removing them from NEP in a separate operation.

## Moved (present in both repositories)

The paths are identical under `examples/` in both. Files marked *modified*
were adapted here so they run on stock Ubuntu netCDF packages; each change is
described in the pull request that moved the file (see `docs/roadmap.md`).

- `classic/coord.c`
- `classic/coord_vars.c`
- `classic/dump_classic_metadata.c`
- `classic/quickstart.c`
- `classic/simple_2D.c`
- `classic/size_limits.c`
- `classic/unlimited_dim.c`
- `classic/var4d.c`
- `f_classic/f_coord.f90`
- `f_classic/f_coord_vars.f90`
- `f_classic/f_dump_classic_metadata.f90`
- `f_classic/f_quickstart.f90`
- `f_classic/f_simple_2D.f90`
- `f_classic/f_size_limits.f90`
- `f_classic/f_unlimited_dim.f90`
- `f_classic/f_var4d.f90`
- `f_netcdf-4/f_chunking_performance.f90`
- `f_netcdf-4/f_compression.f90` *(modified)*
- `f_netcdf-4/f_dump_nc4_metadata.f90`
- `f_netcdf-4/f_format_variants.f90`
- `f_netcdf-4/f_groups.f90`
- `f_netcdf-4/f_multi_unlimited.f90`
- `f_netcdf-4/f_simple_nc4.f90`
- `f_netcdf-4/f_user_types.f90`
- `nczarr/f_nczarr_chunking.f90`
- `nczarr/f_nczarr_compression.f90` *(modified)*
- `nczarr/f_nczarr_enhanced.f90` *(modified)*
- `nczarr/f_nczarr_simple.f90`
- `nczarr/nczarr_chunking.c`
- `nczarr/nczarr_compression.c` *(modified)*
- `nczarr/nczarr_enhanced.c` *(modified)*
- `nczarr/nczarr_simple.c`
- `netcdf-4/chunking_performance.c`
- `netcdf-4/compression.c` *(modified)*
- `netcdf-4/dump_nc4_metadata.c`
- `netcdf-4/format_variants.c`
- `netcdf-4/groups.c`
- `netcdf-4/multi_unlimited.c`
- `netcdf-4/simple_nc4.c`
- `netcdf-4/user_types.c`
- `opendap/f_opendap_constraint.f90`
- `opendap/f_opendap_simple.f90`
- `opendap/f_opendap_subset.f90`
- `opendap/opendap_constraint.c`
- `opendap/opendap_simple.c`
- `opendap/opendap_subset.c`
- `parallelIO/f_square16_par.f90`
- `parallelIO/square16_par.c`
- `performance/bzip2.c` *(modified)*
- `performance/cache_tuning.c`
- `performance/chunking.c`
- `performance/deflate.c`
- `performance/endianness.c`
- `performance/fill_values.c`
- `performance/lz4.c` *(modified)*
- `performance/szip.c`
- `performance/zstandard.c` *(modified)*

## Left in NEP on purpose

- `examples/performance/lossless.c`, `examples/performance/quantize.c`:
  include `nep.h`, so they are Expansion Pack examples, not pure netCDF.
- `examples/pdb`, `examples/dicom`, `examples/viz`: Expansion Pack features.
- Every `CMakeLists.txt`, `test_*.sh`, `test_*.sh.in`, `run_par_examples.sh.in`,
  `validate_cdl.sh.in`, `generate_all_cdl.sh` and `expected_output/*.cdl`:
  NEP's expected-output test harness. This repository runs the programs
  directly under `ctest` instead.
- `examples/performance/*.csv`, `*_metadata.txt`, `plot_*.py`,
  `generate_plots.py`, `*.png`: benchmark results and plots, not sources.
- `examples/opendap/README.md`: its content is in this repository's
  `README.md` and `examples/README.md`.
- `examples/README.md`, `examples/examples.dox`: NEP's own documentation.

Once the moved sources are deleted from NEP, the directories `classic`,
`f_classic`, `netcdf-4`, `f_netcdf-4`, `nczarr`, `opendap` and `parallelIO`
will contain only build and test scaffolding and can be removed along with
their entries in `examples/CMakeLists.txt`; `performance` keeps `lossless.c`
and `quantize.c`.
