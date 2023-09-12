# Copyright (C) 2023 Toitware ApS.
# Use of this source code is governed by a Zero-Clause BSD license that can
# be found in the tests/TESTS_LICENSE file.

# Determine the installed version of xxd:
execute_process(
  COMMAND bash ./tests/get-xxd-version.sh
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  OUTPUT_VARIABLE XXD_VERSION
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Log the XXD version.
message("XXD version: ${XXD_VERSION}")

file(GLOB TESTS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "*.options")

set(TEST_TIMEOUT 40 CACHE STRING "The maximal amount of time each test is allowed to run")

include(ProcessorCount)
ProcessorCount(NUM_CPU)

add_custom_target(
  check
  COMMAND ${CMAKE_CTEST_COMMAND} -j${NUM_CPU} -T test --output-on-failure
  USES_TERMINAL
)

set(TEST_PREFIX "")
set(FAILING_TESTS "")
# Tests that fail always.
include(fail.cmake OPTIONAL)
# Tests that fail on an old version of xxd.
# My workstation: 2022-01-14 new
# Ubuntu runner:  2021-10-22 old
# Windows runner: ??
# Mac runner:     2022-01-14 new
if (XXD_VERSION LESS 2022)
  include(fail-xxd-old.cmake OPTIONAL)
endif()
# Tests that fail on a new version of xxd.
if (XXD_VERSION GREATER 2021)
  include(fail-xxd-new.cmake OPTIONAL)
endif()

message("Failing tests: ${FAILING_TESTS}")
message("Skipped tests: ${SKIP_TESTS}")

foreach(file ${TESTS})
  set(test_name "/tests/${file}")
  if("${test_name}" IN_LIST SKIP_TESTS)
    continue()
  endif()

  add_test(
    NAME "${test_name}"
    COMMAND "sh" "tests/compare-xxd.sh" ${TOIT_EXEC} "tests/${file}"
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  )

  set_tests_properties(${test_name} PROPERTIES TIMEOUT ${TEST_TIMEOUT})

  if ("${test_name}" IN_LIST FAILING_TESTS)
    set_tests_properties("${test_name}" PROPERTIES WILL_FAIL TRUE)
  endif()

endforeach()

