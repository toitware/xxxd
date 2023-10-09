# Copyright (C) 2023 Toitware ApS.
# Use of this source code is governed by a Zero-Clause BSD license that can
# be found in the tests/TESTS_LICENSE file.

cmake_minimum_required(VERSION 3.23)

project(host)

# Add windows exe extension.
set(TOIT_EXEC "toit.run${CMAKE_EXECUTABLE_SUFFIX}" CACHE FILEPATH "The executable used to run the tests")
set(TPKG_EXEC "toit.pkg${CMAKE_EXECUTABLE_SUFFIX}" CACHE FILEPATH "The executable used to install the packages")
set(TCOMPILE_EXEC "toit.compile${CMAKE_EXECUTABLE_SUFFIX}" CACHE FILEPATH "The executable used to check the syntax")

set(DEFAULT_SDK_VERSION CACHE STRING "The default SDK version to use")

set(XXXD_GIT_VERSION "$ENV{XXXD_GIT_VERSION}")
if ("${XXXD_GIT_VERSION}" STREQUAL "")
  include(tools/gitversion.cmake)
  # The Git version is only computed when cmake generates the Ninja files, but
  # that should be good enough.
  compute_git_version(XXXD_GIT_VERSION)
endif()

# Replace the version in app/version.toit.
configure_file(
  app/version.toit.in
  ${CMAKE_CURRENT_SOURCE_DIR}/app/version.toit
  @ONLY)

enable_testing()
add_subdirectory(app)
add_subdirectory(tests)
