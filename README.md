# The NetCDF Developer's Handbook

Example programs for the books by Edward Hartnett:

<table>
  <tr>
    <td align="center" width="50%">
      <a href="https://www.amazon.com/NetCDF-Developers-Handbook-Authoritative-High-Performance/dp/B0GYP4R5ZZ/">
        <img src="docs/images/netcdf_developers_handbook_cover.jpg" alt="The NetCDF Developer's Handbook cover" width="300">
      </a>
      <br>
      <a href="https://www.amazon.com/NetCDF-Developers-Handbook-Authoritative-High-Performance/dp/B0GYP4R5ZZ/"><b>The NetCDF Developer's Handbook</b></a>
      <br>
      The Authoritative Guide to Writing High-Performance Programs for Scientific Data Management
    </td>
    <td align="center" width="50%">
      <a href="https://www.amazon.com/Earth-Observation-Practice-Mission-Mission/dp/B0HJRZ9F7L/">
        <img src="docs/images/earth_observation_in_practice_cover.jpg" alt="Earth Observation in Practice cover" width="300">
      </a>
      <br>
      <a href="https://www.amazon.com/Earth-Observation-Practice-Mission-Mission/dp/B0HJRZ9F7L/"><b>Earth Observation in Practice</b></a>
      <br>
      A Mission-by-Mission Guide to Reading Satellite Data with NetCDF and Python
    </td>
  </tr>
</table>

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

## Building and running the examples

Requirements: CMake 3.16 or later, a C compiler, and netCDF-C (with HDF5)
installed so that `nc-config` can be found.

```sh
cmake -S . -B build -DNETCDF_PREFIX=/usr/local/netcdf-c -DHDF5_PREFIX=/usr/local/hdf5-2.1.1
cmake --build build
ctest --test-dir build --output-on-failure
```

Omit `NETCDF_PREFIX` and `HDF5_PREFIX` if `nc-config` is already on your
`PATH` (for example when netCDF is installed from your distribution's
packages). `ctest` runs every example that does not need an external data
file.

## License

See [LICENSE](LICENSE).
