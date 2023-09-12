# Copyright (C) 2023 Toitware ApS.
# Use of this source code is governed by a Zero-Clause BSD license that can
# be found in the tests/TESTS_LICENSE file.

cmake_minimum_required(VERSION 3.23)

project(host)

# Add windows exe extension.
set(TOIT_EXEC "toit.run${CMAKE_EXECUTABLE_SUFFIX}" CACHE FILEPATH "The executable used to run the tests")
set(TPKG_EXEC "toit.pkg${CMAKE_EXECUTABLE_SUFFIX}" CACHE FILEPATH "The executable used to install the packages")
set(TCOMPILE_EXEC "toit.compile${CMAKE_EXECUTABLE_SUFFIX}" CACHE FILEPATH "The executable used to check the syntax")

enable_testing()
add_subdirectory(app)
add_subdirectory(tests)

