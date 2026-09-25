cmake_minimum_required(VERSION 3.18)
project(NetCDF_Developers_Handbook LANGUAGES C)

set(NETCDF_PREFIX "" CACHE PATH "netCDF-C install prefix (directory containing bin/nc-config)")
set(HDF5_PREFIX "" CACHE PATH "HDF5 install prefix (only needed if not on the default library path)")
option(ENABLE_FORTRAN "Build the Fortran examples if nf-config can be found" ON)
set(NETCDF_FORTRAN_PREFIX "" CACHE PATH "netCDF-Fortran install prefix (directory containing bin/nf-config)")

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(NetCDFExamples)

enable_testing()
add_subdirectory(examples)
