# Roadmap for NetCDF Developers Handbook

## Version 1.1 - Use get_vara/put_vara in Several Examples

### Goal

Most of the example programs use `nc_put_var_*()` and `nc_get_var_*()` to write and read entire netCDF variables in one call. This is simple and works well for the small data in the examples, but is not how most real code looks. We need to use the vara versions, with explicit `start`/`count` arrays, in enough examples that readers see the pattern.

We do not need to change every example, only a few characteristic ones. The conversions must keep the same file names, output files, and validation logic so the existing CI tests continue to pass unchanged.

### Scope

Convert these programs from whole-variable calls to `nc_put_vara_*` / `nc_get_vara_*` (C) and to `nf90_put_var` / `nf90_get_var` with explicit `start` and `count` arguments (Fortran):

- `examples/classic/var4d.c` and `examples/f_classic/f_var4d.f90`
- `examples/netcdf-4/compression.c` and `examples/f_netcdf-4/f_compression.f90`
- `examples/classic/simple_2D.c` and `examples/f_classic/f_simple_2D.f90`
- `examples/classic/unlimited_dim.c` and `examples/f_classic/f_unlimited_dim.f90`

Leave these unchanged:

- Metadata-dump examples (`dump_classic_metadata.c`, `dump_nc4_metadata.c`): they read whole files by design.
- Group and user-type examples (`groups.c`, `user_types.c`): the vara API is not the point of these.
- The smallest examples (`quickstart.c`, `coord.c`, `coord_vars.c`): whole-variable calls are clearer at that level.
- `performance/` examples: they already demonstrate chunked/filtered I/O and are large enough that a vara conversion would be cosmetic.
- NcZarr, OPeNDAP and parallel I/O examples: out of scope for this release.

No build-system, CI, or dependency changes are needed.

### Design decisions

- Keep file names, created `.nc` files, console output, and validation logic identical. Only the API calls and the surrounding comments change.
- Declare `size_t start[ndims]` and `size_t count[ndims]` at the point of use, even when the start is all zeros and the count is the full dimension length. This makes the vara pattern visible.
- For partial-write examples (`simple_2D`, `compression`, `unlimited_dim`) keep the existing subset semantics on write and use a matching `start`/`count` on read.
- For Fortran use 1-based `start_idx` and `count_idx` arrays, consistent with the naming already in `f_compression.f90` and `f_simple_2D.f90`.
- Update the `@brief` block and learning objectives of each converted file to mention `start`/`count` arrays and the vara API.
- No new tests: the converted programs must still exit 0 under the existing `ctest` registration.

### Sprints

#### Sprint 1 - var4d C and Fortran

Convert the clearest multi-dimensional example to vara calls. `var4d.c` currently writes and reads three variables (2D, 3D, 4D) with whole-variable calls; `f_var4d.f90` is the same.

Deliverables: `var4d.c` and `f_var4d.f90` use explicit `start`/`count` arrays for every write and read; both tests pass under `ctest`.

#### Sprint 2 - compression C and Fortran

Complete the vara pattern in the compression example. The write side already uses `nc_put_vara_float` (C) and `nf90_put_var` with `start`/`count` (Fortran); only the read side and the zstd availability probe still use whole-variable calls.

Deliverables: `compression.c` and `f_compression.f90` read back data with vara calls; the zstd probe in `compression.c` also uses vara.

#### Sprint 3 - simple_2D and unlimited_dim C and Fortran

Convert two examples that already use vara for writing so they also use vara for reading.

Deliverables: `simple_2D.c`, `f_simple_2D.f90`, `unlimited_dim.c`, and `f_unlimited_dim.f90` use vara calls for both writes and reads.

#### Sprint 4 - Documentation and v1.1 release

Update the examples table to highlight which programs demonstrate `start`/`count` arrays, then tag the release.

Deliverables: `examples/README.md` updated, roadmap marked done, `v1.1` tag created after merge.

### Sprint 1 plan

Scope: `examples/classic/var4d.c` and `examples/f_classic/f_var4d.f90`.

1. **var4d.c**
   - Replace the three `nc_put_var_float` calls with `nc_put_vara_float` using:
     - 2D `temp_surface`: `start={0,0}`, `count={NLAT,NLON}`
     - 3D `temp_profile`: `start={0,0,0}`, `count={NTIME,NLAT,NLON}`
     - 4D `temp_3d`: `start={0,0,0,0}`, `count={NTIME,NLEVEL,NLAT,NLON}`
   - Replace the three `nc_get_var_float` calls with matching `nc_get_vara_float` calls using the same start/count arrays.
   - Add a short comment above the write block explaining that `start`/`count` select the subset being written (here, the whole variable).
   - Update the `@brief` learning objectives to include using `nc_put_vara_*` / `nc_get_vara_*` with explicit `start`/`count` arrays.
2. **f_var4d.f90**
   - Replace the three `nf90_put_var` calls with `nf90_put_var(..., start=..., count=...)` using 1-based arrays:
     - 2D `temp_surface`: `start_idx=(/1,1/)`, `count_idx=(/NLON,NLAT/)`
     - 3D `temp_profile`: `start_idx=(/1,1,1/)`, `count_idx=(/NLON,NLAT,NTIME/)`
     - 4D `temp_3d`: `start_idx=(/1,1,1,1/)`, `count_idx=(/NLON,NLAT,NLEVEL,NTIME/)`
   - Replace the three `nf90_get_var` calls similarly.
   - Update the docstring learning objectives.
3. **Local verification**
   - `cmake --build build && ctest --test-dir build --output-on-failure`
   - `var4d` and `f_var4d` pass and produce identical `var4d.nc` / `f_var4d.nc` files as before.
4. **CI**
   - Existing workflow runs the modified tests; no workflow changes needed.

Definition of done for Sprint 1: `var4d` and `f_var4d` tests pass locally and in CI, and both sources use explicit `start`/`count` arrays for all I/O.

### Sprint 2 plan

Scope: `examples/netcdf-4/compression.c` and `examples/f_netcdf-4/f_compression.f90`.

1. **compression.c**
   - In `read_compressed_file`, replace `nc_get_var_float(ncid, varid, data)` with `nc_get_vara_float` using `start={0,0,0}` and `count={NTIME,NLAT,NLON}`. The full read still returns `FILL_VALUE` for the unwritten last timestep, so the existing fill-value validation is unchanged.
   - In `check_zstd_support`, replace the single-element `nc_put_var_float` and `nc_get_var_float` with `nc_put_vara_float` / `nc_get_vara_float` using `start={0}` and `count={1}`.
   - Update the `@brief` to note that even full-variable reads are done with `nc_get_vara_*` so the pattern stays consistent with the partial write.
2. **f_compression.f90**
   - In `read_compressed_file`, replace `nf90_get_var(ncid, varid, data)` with `nf90_get_var(ncid, varid, data, start=start_idx, count=count_idx)` where `start_idx=(/1,1,1/)` and `count_idx=(/NLON,NLAT,NTIME/)`.
   - The zstd probe there is compile-time guarded (`#ifdef HAVE_NF90_ZSTANDARD`) and only checks define-time calls; leave it as-is unless it is expanded to do I/O, in which case use vara calls.
   - Update the docstring learning objectives.
3. **Local verification**
   - Build and run `compression` and `f_compression`.
   - Confirm the set of created files (`compress_*.nc`, `f_compress_*.nc`) and the results table are unchanged.
   - `ctest --test-dir build --output-on-failure` passes for both.
4. **CI**
   - Existing workflow runs the modified tests; no workflow changes needed.

Definition of done for Sprint 2: `compression` and `f_compression` tests pass locally and in CI, and all data I/O in them uses explicit `start`/`count`.

### Sprint 3 plan

Scope: `examples/classic/simple_2D.c`, `examples/f_classic/f_simple_2D.f90`, `examples/classic/unlimited_dim.c`, `examples/f_classic/f_unlimited_dim.f90`.

1. **simple_2D.c**
   - The write already uses `nc_put_vara_int` with `count={NY-1,NX}`; leave it unchanged.
   - Replace the read `nc_get_var_int(ncid, varid, &data_in[0][0])` with `nc_get_vara_int` using `start={0,0}` and `count={NY,NX}`, so explicit subset selection is visible on both sides and the fill-value check on the unwritten last row still works.
   - Update the `@brief` to note vara calls are used for both the partial write and the full read.
2. **f_simple_2D.f90**
   - The write already uses `nf90_put_var(..., start=start_idx, count=count_idx)`; leave it unchanged.
   - Replace the read `nf90_get_var(ncid, varid, data_in)` with `nf90_get_var(ncid, varid, data_in, start=start_idx, count=count_idx)` where `start_idx=(/1,1/)` and `count_idx=(/NX,NY/)`.
   - Update the docstring learning objectives.
3. **unlimited_dim.c**
   - The writes already use `nc_put_vara_float`; leave them unchanged.
   - Replace the read of the `time` coordinate with `nc_get_vara_float` using `start={0}` and `count={TOTAL_TIMESTEPS}`.
   - Replace the read of `temperature` with `nc_get_vara_float` using `start={0,0,0}` and `count={TOTAL_TIMESTEPS,NLAT,NLON}`.
   - Update the `@brief` to mention reads use `start`/`count` too.
4. **f_unlimited_dim.f90**
   - The writes already use `nf90_put_var(..., start=..., count=...)`; leave them unchanged.
   - Replace the read of `time` with `nf90_get_var(ncid, time_varid, time_in, start=(/1/), count=(/TOTAL_TIMESTEPS/))`.
   - Replace the read of `temperature` with `nf90_get_var(ncid, temp_varid, temp_in, start=(/1,1,1/), count=(/NLON,NLAT,TOTAL_TIMESTEPS/))`.
   - Update the docstring learning objectives.
5. **Local verification**
   - `ctest --test-dir build --output-on-failure`
   - `simple_2D`, `f_simple_2D`, `unlimited_dim`, and `f_unlimited_dim` all pass.
6. **CI**
   - Existing workflow runs the modified tests; no workflow changes needed.

Definition of done for Sprint 3: all four tests pass locally and in CI, and every write and read in them uses explicit `start`/`count` arrays.

### Sprint 4 plan

Scope: documentation and the v1.1 release. No source changes.

1. **`examples/README.md`**
   - In the `classic/` table, extend the `Demonstrates` column for `simple_2D`, `var4d`, and `unlimited_dim` to mention explicit `start`/`count` arrays (one short phrase per row, e.g. "2D integer array written and read with `start`/`count`").
   - In the `netcdf-4/` table, update the `compression` row similarly.
2. **Top-level README**
   - Check the quick-start/description for any whole-variable wording and update it to match; keep the link to `examples/README.md`.
3. **Release**
   - Mark Version 1.1 done in this roadmap.
   - After the final PR merges, tag `v1.1` on `main` and create a GitHub release pointing at it (done on request, as with v1.0).

Definition of done for Sprint 4: documentation reflects the vara conversions, the roadmap shows Version 1.1 complete, and `v1.1` is tagged.

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
| `examples/classic` | C | quickstart, simple_2D, coord, coord_vars, var4d, unlimited_dim, size_limits, dump_classic_metadata | dump_classic_metadata reads the file written by coord_vars |
| `examples/netcdf-4` | C | simple_nc4, groups, compression, chunking_performance, user_types, multi_unlimited, format_variants, dump_nc4_metadata | dump_nc4_metadata reads the file written by user_types; compression needs netCDF-C >= 4.9 headers (zstd skipped at runtime if the plugin is absent) |
| `examples/performance` | C | deflate, bzip2, lz4, szip, zstandard, chunking, cache_tuning, endianness, fill_values | Filter examples need the matching HDF5 filter plugin; `lossless.c` and `quantize.c` stay in NEP (use `nep.h`). Only sources move, not CSV results or plot scripts |
| `examples/nczarr` | C, Fortran | nczarr_simple, nczarr_chunking, nczarr_compression, nczarr_enhanced (+ `f_` versions) | Requires netcdf-c built with NcZarr |
| `examples/f_classic` | Fortran | f_ versions of the classic examples | Requires netcdf-fortran |
| `examples/f_netcdf-4` | Fortran | f_ versions of the netcdf-4 examples | Requires netcdf-fortran |
| `examples/opendap` | C, Fortran | opendap_simple, opendap_subset, opendap_constraint (+ `f_` versions) | Needs network access to a remote server; build-only in CI |
| `examples/parallelIO` | C, Fortran | square16_par, f_square16_par | Needs MPI and parallel netcdf-c; optional, off by default |

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
  (bzip2/lz4/szipgit@github.com:captainkirk99/NetCDF_Developers_Handbook.git/zstandard only when the plugin is found).
- Each runnable example is registered with `add_test()` so `ctest` runs it;
  examples that read a file written by another example declare a ctest
  `DEPENDS` on it. NEP's `test_*.sh` wrappers, `validate_cdl.sh` and
  `expected_output/` are not moved: passing means the example exits 0. No
  test code is written.
- CI is GitHub Actions on `ubuntu-latest`, using apt `libnetcdf-dev`,
  `libhdf5-dev` and `libnetcdff-dev`. Data-file and network examples are
  built but not run.

### Sprints

#### Sprint 1 - Skeleton, classic and netcdf-4 C examples, CI (done)

Deliverables: README with both books and covers (done first so it can be
iterated on while the rest of the sprint proceeds), repo builds with CMake,
`classic/` and `netcdf-4/` C examples build and run locally against
`/usr/local/netcdf-c`, GitHub Actions runs them on every push/PR.

#### Sprint 2 - README fix, performance examples (done)

- README: *Earth Observation in Practice* is a separate book with its own
  examples repo; present it as a "see also" rather than as a book these
  examples belong to.
- Move `performance/*.c` (minus `lossless.c`, `quantize.c`), build all of
  them, run them under `ctest`; bzip2/lz4/zstandard skip cleanly when the
  filter plugin is not installed.
- Document filter plugins and `HDF5_PLUGIN_PATH` in the README.

#### Sprint 3 - Fortran examples (done)

- Move `f_classic/`, `f_netcdf-4/`; add `nf-config`
  detection and the `ENABLE_FORTRAN` option.
- Verify locally (requires installing netcdf-fortran against
  `/usr/local/netcdf-c`) and in CI with `libnetcdff-dev` and `gfortran`.

#### Sprint 4 - NcZarr, OPeNDAP and parallel I/O (done)

- Move `nczarr/` (C and Fortran); built and run when `nc-config --has-nczarr`.
- Move `opendap/` (C and Fortran); built when `nc-config --has-dap`, never
  run in CI (network).
- Move `parallelIO/` behind `ENABLE_PARALLEL` (off by default); separate CI
  job with OpenMPI and apt `libnetcdf-mpi-dev`.

#### Sprint 5 - Documentation and release (planned below)

- `examples/README.md`: table of all examples, what each demonstrates, how
  to build and run.
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
   - Root `CMakeLists.txt` (`cmake_minimum_required(VERSION 3.18)`, project
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
   - Copy `classic/*.c` from `~/NEP/examples`, unchanged.
   - Rewrite `classic/CMakeLists.txt` on top of the shared logic; register
     each program with `add_test()`; `dump_classic_metadata` runs on
     `coord_vars.nc` and depends on the `coord_vars` test.
4. **Move netcdf-4 C examples**
   - Same for `netcdf-4/*.c`; `dump_nc4_metadata` runs on `user_types.nc`.
5. **Local verification**
   - `cmake -S . -B build -DNETCDF_PREFIX=/usr/local/netcdf-c -DHDF5_PREFIX=/usr/local/hdf5-2.1.1`
   - `cmake --build build && ctest --test-dir build --output-on-failure`
   - All 16 C programs build and every example runs and exits 0.
6. **CI**
   - `.github/workflows/ci.yml`: on push and pull_request, `ubuntu-latest`,
     `apt-get install libnetcdf-dev libhdf5-dev cmake`, configure, build,
     `ctest --output-on-failure`.
   - Add the workflow status badge and final build/run quick start to the
     README.

Definition of done for Sprint 1: CI green on `main`, `ctest` passes locally
against `/usr/local/netcdf-c`, README shows both books with covers, no
changes made to the NEP repo.

### Sprint 2 plan

Scope: README correction, `examples/performance` (C only).

1. **README**
   - Only *The NetCDF Developer's Handbook* is the book these examples
     accompany. Move *Earth Observation in Practice* to a "See also" section
     (cover, Amazon link, its own examples repo at
     https://github.com/captainkirk99/Earth_Observation_in_Practice) worded
     as "for more netCDF examples see my other book", and state that the
     examples here are unrelated to it.
2. **Move performance C examples**
   - Copy `performance/{bzip2,cache_tuning,chunking,deflate,endianness,
     fill_values,lz4,szip,zstandard}.c` from `~/NEP/examples`. Leave behind
     `lossless.c`/`quantize.c` (need `nep.h`), the CSV results, plot scripts,
     PNGs and `*_metadata.txt`.
   - `performance/CMakeLists.txt` on the shared logic: build all nine,
     register all nine with `add_test()`, `RUN_SERIAL` (each writes a
     ~130 MB scratch file). `ENABLE_BENCHMARKS` option compiles
     `cache_tuning` with its timing sweeps.
   - bzip2/lz4/zstandard: add a `filter_available()` check
     (`nc_inq_filter_avail`) at the top of `main()` that prints a skipping
     message and exits 0 when the HDF5 plugin cannot be loaded. Without it
     the programs fail on `undefined filter` on any system, such as the
     Ubuntu CI runner, that has netCDF >= 4.9 but no plugins.
   - No source changes to the other six programs. `deflate` (~18 s) and
     `szip` (~5 s) are the only slow tests; the rest run in about a second.
3. **Local verification**
   - Same commands as Sprint 1; all 25 tests pass against
     `/usr/local/netcdf-c` (which has no plugins, so the three filter
     examples report skipping).
4. **CI**
   - Existing workflow picks up the new directory; no new job. Ubuntu
     packages no bzip2/lz4/zstd HDF5 plugins, so those three build and skip
     in CI.
5. **README build notes**
   - How to install filter plugins and set `HDF5_PLUGIN_PATH`, and the
     `ENABLE_BENCHMARKS` option.

Definition of done for Sprint 2: CI green on `main`, 25 `ctest` tests pass
locally, README presents the second book as "see also".

### Sprint 3 plan

Scope: `examples/f_classic`, `examples/f_netcdf-4` (Fortran 90 versions of
the Sprint 1 C examples).

1. **Build system**
   - Root: `option(ENABLE_FORTRAN ON)` and `NETCDF_FORTRAN_PREFIX` cache
     variable. The project stays `LANGUAGES C`; Fortran is enabled with
     `enable_language(Fortran)` only when `nf-config` is found.
   - `cmake/NetCDFExamples.cmake`: look for `nf-config` under
     `NETCDF_FORTRAN_PREFIX/bin`, then next to `nc-config`, then `PATH`.
     If found, export `NF_FFLAGS_LIST`/`NF_LIBS_LIST` from
     `nf-config --fflags/--flibs`, add `nf-config --prefix`/lib to the test
     `LD_LIBRARY_PATH`, set `HAVE_NETCDF_FORTRAN`, and provide
     `add_netcdf_fortran_example(name)` (`name.f90`, links `NF_LIBS_LIST`
     then `NC_LIBS_LIST`). If not found, print a status message and skip the
     Fortran directories; the C build is unaffected.
   - `examples/CMakeLists.txt` adds `f_classic` and `f_netcdf-4` when
     `HAVE_NETCDF_FORTRAN`.
2. **Move Fortran examples**
   - Copy the 16 `*.f90` files from `~/NEP/examples/f_classic` and
     `f_netcdf-4`, unchanged. Leave behind `test_*.sh` and the CDL/expected
     output comparisons, as in Sprint 1.
   - `f_classic/CMakeLists.txt` and `f_netcdf-4/CMakeLists.txt`: program
     list plus `add_netcdf_run()`; `f_dump_classic_metadata` runs on
     `f_coord_vars.nc` (DEPENDS `f_coord_vars`), `f_dump_nc4_metadata` on
     `f_user_types.nc` (DEPENDS `f_user_types`).
3. **Local verification**
   - Install `gfortran`; build netCDF-Fortran 4.6.1 from source against
     `/usr/local/netcdf-c` into `/usr/local/netcdf-fortran` (add to the
     environment blueprint).
   - `cmake -S . -B build -DNETCDF_PREFIX=/usr/local/netcdf-c -DNETCDF_FORTRAN_PREFIX=/usr/local/netcdf-fortran`
   - All 41 tests pass (25 C + 16 Fortran). Also check that
     `-DENABLE_FORTRAN=OFF` and a configure without `nf-config` still
     build the C examples.
4. **CI**
   - Add `gfortran` and `libnetcdff-dev` to the apt install in `ci.yml`;
     `nf-config` is then on `PATH` and the Fortran examples run in the same
     job.
5. **README**
   - Fortran requirements, `NETCDF_FORTRAN_PREFIX` in the quick start,
     `ENABLE_FORTRAN` note.

Definition of done for Sprint 3: CI green on `main` with the Fortran
examples running, 41 `ctest` tests pass locally.

### Sprint 4 plan

Scope: `examples/nczarr`, `examples/opendap`, `examples/parallelIO` (C and
Fortran). All three depend on how netCDF-C was configured, so each is an
optional component that the build detects or that the user switches on.

1. **NcZarr** (`nc-config --has-nczarr`)
   - Copy the 4 C and 4 Fortran sources from `~/NEP/examples/nczarr`. Leave
     behind `test_*.sh*`. Two adaptations so they run on netCDF-C 4.9.2
     (this VM and Ubuntu's apt): `*nczarr_compression` skips on
     `NC_ENOFILTER` (NcZarr deflate needs the filter plugin directory),
     `*nczarr_enhanced` falls back to fixed-size dimensions on
     `NC_EDIMSIZE` (NcZarr unlimited dimensions arrived in 4.9.3).
   - `add_netcdf_run()` sets `HDF5_PLUGIN_PATH` from `nc-config --plugindir`
     when that directory exists, so the compression examples exercise the
     real filter path against a netCDF-C built `--with-plugin-dir`.
   - `cmake/NetCDFExamples.cmake` exports `HAVE_NCZARR`;
     `examples/CMakeLists.txt` adds `nczarr` when it is set, otherwise prints
     a status message. The Fortran programs are added when
     `HAVE_NETCDF_FORTRAN` too.
   - All eight write and read back `file://*.zarr#mode=nczarr` directories in
     the build tree, so they run under `ctest` like everything else.
2. **OPeNDAP** (`nc-config --has-dap`)
   - Copy the 3 C and 3 Fortran sources, unchanged (`README.md` stays in
     NEP; its content moves into this repo's README section). Exports
     `HAVE_DAP`; `examples/CMakeLists.txt` adds `opendap` when set.
   - The programs read `http://test.opendap.org/...`, so they are only
     built by default. `option(RUN_OPENDAP_EXAMPLES OFF)` registers them
     with `ctest` for users with network access; CI leaves it off.
3. **Parallel I/O** (`option(ENABLE_PARALLEL OFF)`)
   - Copy `square16_par.c` and `f_square16_par.f90`, unchanged. Leave
     behind `run_par_examples.sh.in` (ncdump/grep validation).
   - `parallelIO/CMakeLists.txt`: `find_package(MPI)`; a parallel-enabled
     netCDF-C is required. Ubuntu's `libnetcdf-mpi-dev` ships no
     `nc-config`, only `pkg-config netcdf-mpi` (and its `.pc` and
     `netCDFConfig.cmake` both point at the wrong include directory), so the
     directory uses `pkg_check_modules(NETCDF_PAR netcdf-mpi)` for the
     library plus a `find_path(netcdf_par.h)` for the headers (override the
     module name with `NETCDF_PARALLEL_PKG`, e.g. `netcdf` for a self-built
     parallel install). The C example is registered as
     `mpiexec -n 4 square16_par` (with `OMPI_MCA_rmaps_base_oversubscribe=1` in the test environment) (both programs insist on
     exactly 4 ranks).
   - `f_square16_par` is built when Fortran is enabled. netCDF-Fortran
     always compiles its parallel entry points and only fails at run time
     (`NF90_ENOPAR`) when the underlying netCDF-C is serial, and there is no
     `nf-config` flag for it, so its run is registered only with
     `-DNETCDF_FORTRAN_PARALLEL=ON`. Apt's `libnetcdff-dev` links the
     serial netCDF-C, so CI builds it but does not run it.
4. **Local verification**
   - Rebuild `/usr/local/netcdf-c` with `--enable-nczarr --enable-dap
     --with-plugin-dir` (libcurl is installed) and update the environment
     blueprint; rebuild netCDF-Fortran against it.
   - Main build: 41 + 8 NcZarr tests pass; the 6 OPeNDAP programs build;
     `-DRUN_OPENDAP_EXAMPLES=ON` runs them from this VM if the network
     allows.
   - Parallel: `apt-get install libopenmpi-dev libhdf5-openmpi-dev
     libnetcdf-mpi-dev`, then a second build with `-DENABLE_PARALLEL=ON`
     runs `square16_par` under `mpiexec -n 4` (this VM needs
     `HWLOC_COMPONENTS=-x86` to stop Open MPI crashing in hwloc).
5. **CI**
   - Existing job: apt netcdf-c reports NcZarr and DAP, so the NcZarr
     examples run and the OPeNDAP ones build.
   - New job `parallel`: `libopenmpi-dev libhdf5-openmpi-dev
     libnetcdf-mpi-dev gfortran libnetcdff-dev`, configure
     `-DENABLE_PARALLEL=ON`, build only the two parallel targets, run
     `ctest -R square16`, with `OMPI_ALLOW_RUN_AS_ROOT*`.
6. **README**
   - Component table: which `nc-config` flag each directory needs, the
     `ENABLE_PARALLEL`, `RUN_OPENDAP_EXAMPLES` and `NETCDF_FORTRAN_PARALLEL`
     options, and the OPeNDAP server/URL note from NEP's `opendap/README.md`.

Definition of done for Sprint 4: both CI jobs green on `main`, 49 `ctest`
tests pass locally in the main build and `square16_par` passes in the
parallel build, OPeNDAP examples build (and run when the network is
available).

### Sprint 5 plan

Scope: documentation and the v1.0 release. No source or build changes.

1. **`examples/README.md`**
   - One section per directory (classic, netcdf-4, performance, NcZarr,
     OPeNDAP, parallel I/O) with a program/what-it-demonstrates table, the
     capability each directory needs, and how to run one program by hand.
     Descriptions come from the `@brief` header of each source. The sources
     do not reference book chapters, so the table is organised by topic
     rather than by chapter.
   - Fortran twins are described once ("each C program has an `f_` twin")
     rather than duplicated row by row.
2. **NEP handoff** (`docs/nep-handoff.md`)
   - Generated by comparing `examples/` here with `~/NEP/examples`: every
     moved source (57 files: 16 + 9 + 16 + 8 + 6 + 2), marking the 9 that
     were modified on the way, plus the explicit list of what stays in NEP
     (`lossless.c`, `quantize.c`, `pdb`, `dicom`, `viz`, the test harness,
     benchmark CSVs/plots).
3. **Top-level README**
   - Link `examples/README.md` from "What is here"; drop the "being moved"
     sentence since the move is complete; link the handoff list.
4. **Release**
   - Roadmap marked done. After the PR merges, tag `v1.0` on `main` and
     create a GitHub release pointing at it (needs a push to `main`, so it
     is done on request rather than from the PR branch).
