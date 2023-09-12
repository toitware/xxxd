# Copyright (C) 2023 Toitware ApS.
# Use of this source code is governed by a Zero-Clause BSD license that can
# be found in the tests/TESTS_LICENSE file.

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
# Tests that fail locally and on toitlang/toit.
include(fail.cmake OPTIONAL)
# Tests that only fail when called with this test runner.
include(fail_pkg.cmake OPTIONAL)

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

