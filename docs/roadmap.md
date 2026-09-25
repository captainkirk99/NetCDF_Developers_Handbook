# Roadmap

## Version 1.0 - Examples from the NetCDF Expansion Pack

### Goal

Move the pure-netCDF example programs out of the NetCDF Expansion Pack (NEP,
checked out locally at `~/NEP`, on GitHub at
https://github.com/Intelligent-Data-Design-Inc/NEP) into this repo, under
`examples/`, with a standalone CMake build and a CI system that proves the
examples build and run.

### Requirements

- Only pure netCDF examples. Nothing that includes `nep.h` or depends on the
  Expansion Pack (PDB, DICOM, viz, `performance/lossless.c`,
  `performance/quantize.c`) is moved.
- Examples live in the `examples/` subdirectory, keeping the NEP subdirectory
  layout (`classic/`, `netcdf-4/`, ...).
- The NEP repo is not modified. Removal of the examples from NEP is a separate
  operation.
- CMake build system. For local build tests use `/usr/local/hdf5-2.1.1` and
  `/usr/local/netcdf-c`.
- CI checks that the examples build and run successfully (only those that need
  no external data file). No test framework, no mocked data; the examples
  themselves are the tests.
- README mentions both books, with cover images:
  - *Earth Observation in Practice*:
    https://www.amazon.com/Earth-Observation-Practice-Mission-Mission/dp/B0HJRZ9F7L/
  - *NetCDF Developers Handbook*:
    https://www.amazon.com/NetCDF-Developers-Handbook-Authoritative-High-Performance/dp/B0GYP4R5ZZ/

### Inventory of examples to move

| NEP directory | Language | Programs | Notes |
|---|---|---|---|
| `examples/classic` | C | quickstart, simple_2D, coord, coord_vars, var4d, unlimited_dim, size_limits, dump_classic_metadata | dump_classic_metadata reads the file written by coord_vars and is diffed against `expected_output/` |
| `examples/netcdf-4` | C | simple_nc4, groups, compression, chunking_performance, user_types, multi_unlimited, format_variants, dump_nc4_metadata | dump/format/groups have shell wrappers and expected output |
| `examples/performance` | C | deflate, bzip2, lz4, szip, zstandard, chunking, cache_tuning, endianness, fill_values | Filter examples need the matching HDF5 filter plugin; `lossless.c` and `quantize.c` stay in NEP (use `nep.h`). Only sources move, not CSV results or plot scripts |
| `examples/nczarr` | C, Fortran | nczarr_simple, nczarr_chunking, nczarr_compression, nczarr_enhanced (+ `f_` versions) | Requires netcdf-c built with NcZarr |
| `examples/f_classic` | Fortran | f_ versions of the classic examples | Requires netcdf-fortran |
| `examples/f_netcdf-4` | Fortran | f_ versions of the netcdf-4 examples | Requires netcdf-fortran |
| `examples/opendap` | C, Fortran | opendap_simple, opendap_subset, opendap_constraint (+ `f_` versions) | Needs network access to a remote server; build-only in CI |
| `examples/parallelIO` | C, Fortran | square16_par, f_square16_par | Needs MPI and parallel netcdf-c; optional, off by default |
| `examples/expected_output` | text | expected `.txt` output for the dump/format/groups wrappers | Only the files referenced by moved examples |

Not moved: `examples/pdb`, `examples/dicom`, `examples/viz`.

### Design decisions

- Top-level `CMakeLists.txt` in the repo root, `add_subdirectory(examples)`,
  one `CMakeLists.txt` per example directory. NetCDF flags come from
  `nc-config` (and `nf-config` for Fortran), found via `NETCDF_PREFIX` /
  `HDF5_PREFIX` cache variables or `PATH`, so the same build works against
  `/usr/local/netcdf-c` locally and apt packages in CI.
- Options, all following the NEP names where they exist:
  `ENABLE_FORTRAN` (default ON if netcdf-fortran found), `ENABLE_NCZARR`
  (auto-detected from `nc-config --has-nczarr`), `ENABLE_OPENDAP` (default
  OFF), `ENABLE_PARALLEL` (default OFF), `ENABLE_PERFORMANCE_FILTERS`
  (bzip2/lz4/szip/zstandard only when the plugin is found).
- Each runnable example is registered with `add_test()` so `ctest` runs it;
  the existing `test_*.sh` wrappers are kept for the examples that need a
  producer step or an expected-output diff. No new test code is written.
- CI is GitHub Actions on `ubuntu-latest`, using apt `libnetcdf-dev`,
  `libhdf5-dev` and `libnetcdff-dev`. Data-file and network examples are
  built but not run.

### Sprints

#### Sprint 1 - Skeleton, classic and netcdf-4 C examples, CI (planned below)

Deliverables: README with both books and covers (done first so it can be
iterated on while the rest of the sprint proceeds), repo builds with CMake,
`classic/` and `netcdf-4/` C examples build and run locally against
`/usr/local/netcdf-c`, GitHub Actions runs them on every push/PR.

#### Sprint 2 - Performance examples and expected-output wrappers

- Move `performance/*.c` (minus `lossless.c`, `quantize.c`) and their
  `CMakeLists.txt`; add filter-plugin detection so bzip2/lz4/szip/zstandard
  build only when available and are skipped cleanly otherwise.
- Move `expected_output/` files referenced by the classic/netcdf-4 wrappers
  (if not already done in Sprint 1) and confirm the wrapper scripts pass under
  `ctest`.
- Set `HDF5_PLUGIN_PATH` in the test environment; document in
  `examples/README.md` how to install the filter plugins.
- CI: add a job that installs the plugin packages available on Ubuntu and runs
  the performance examples with a short runtime configuration.

#### Sprint 3 - Fortran examples

- Move `f_classic/`, `f_netcdf-4/` and their wrappers; add `nf-config`
  detection and the `ENABLE_FORTRAN` option.
- Verify locally (requires installing netcdf-fortran against
  `/usr/local/netcdf-c`) and in CI with `libnetcdff-dev` and `gfortran`.

#### Sprint 4 - NcZarr, OPeNDAP and parallel I/O (optional components)

- Move `nczarr/` (C and Fortran) with `ENABLE_NCZARR` auto-detection; run in
  CI only if the apt netcdf-c reports NcZarr support.
- Move `opendap/` with `ENABLE_OPENDAP` (build-only, never run in CI).
- Move `parallelIO/` with `ENABLE_PARALLEL` (off by default; separate CI job
  with `mpich` and parallel netcdf-c if apt provides it, otherwise build-only).

#### Sprint 5 - Documentation and release

- `examples/README.md`: table of all examples, what each demonstrates, which
  book chapter it accompanies, how to build and run.
- Tag `v1.0`. Hand off the list of moved files so they can be removed from
  NEP in a separate operation.

### Sprint 1 plan

Scope: README, `examples/classic`, `examples/netcdf-4` (C only), build
system, CI.

1. **README**
   - Short description of the repo and its relation to the two books, links
     to both Amazon pages, cover images stored in `docs/images/` (fetched
     from the Amazon listings), placeholder build/run quick start that is
     filled in as the build system lands.
   - Delivered as its own PR at the start of the sprint so it can be
     iterated on independently of the example work.
2. **Repo skeleton**
   - Root `CMakeLists.txt` (`cmake_minimum_required(VERSION 3.16)`, project
     `NetCDF_Developers_Handbook` LANGUAGES C, `enable_testing()`,
     `add_subdirectory(examples)`).
   - `examples/CMakeLists.txt` adding `classic` and `netcdf-4`.
   - Shared CMake logic (`cmake/FindNetCDFConfig.cmake` or a small include)
     that locates `nc-config` from `NETCDF_PREFIX`, `HDF5_PREFIX` or `PATH`
     and exports `NC_CFLAGS_LIST`, `NC_LIBS_LIST`, `NC_LIBDIR` and the
     `LD_LIBRARY_PATH` test environment, so per-directory CMake files are
     just a program list plus `add_test()` lines.
   - `.gitignore` additions for `build/` and `*.nc`.
3. **Move classic C examples**
   - Copy `classic/*.c`, `classic/test_*.sh` and the referenced
     `expected_output/*.txt` from `~/NEP/examples`, unchanged apart from
     removing any NEP-specific include paths.
   - Adapt `classic/CMakeLists.txt` to the shared logic; register each
     program with `add_test()`, wrappers used where NEP uses them
     (`test_coord.sh`, `test_quickstart.sh`, `test_dump_classic_metadata.sh`).
4. **Move netcdf-4 C examples**
   - Same for `netcdf-4/*.c`, its wrappers (`test_dump_nc4_metadata.sh`,
     `test_format_variants.sh`, `test_groups.sh`) and expected output.
5. **Local verification**
   - `cmake -S . -B build -DNETCDF_PREFIX=/usr/local/netcdf-c -DHDF5_PREFIX=/usr/local/hdf5-2.1.1`
   - `cmake --build build && ctest --test-dir build --output-on-failure`
   - All 16 C programs build; every example that needs no external data runs
     and exits 0; the three diff wrappers pass.
6. **CI**
   - `.github/workflows/ci.yml`: on push and pull_request, `ubuntu-latest`,
     `apt-get install libnetcdf-dev libhdf5-dev cmake`, configure, build,
     `ctest --output-on-failure`.
   - Add the workflow status badge and final build/run quick start to the
     README.

Definition of done for Sprint 1: CI green on `main`, `ctest` passes locally
against `/usr/local/netcdf-c`, README shows both books with covers, no
changes made to the NEP repo.
