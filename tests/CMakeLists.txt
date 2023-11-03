# Copyright (C) 2023 Toitware ApS.
# Use of this source code is governed by a Zero-Clause BSD license that can
# be found in the tests/TESTS_LICENSE file.

# Determine the installed version of xxd:
execute_process(
  COMMAND ./tests/get-xxd-version.sh
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  OUTPUT_VARIABLE XXD_VERSION
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Log the XXD version.
message("XXD version: '${XXD_VERSION}'")

# Tests where we compare with the Unix version of the tool.
file(GLOB UNIX_XXD_TESTS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "xxd-unix/*.options")
file(GLOB UNIX_TR_TESTS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "tr-unix/*.options")
# Tests where we compare with gold files.
file(GLOB XXXD_TESTS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "xxxd/*.xxxd-options")
file(GLOB TR_TESTS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "tr/*.tr-options")

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
# Windows runner: Gets no version number, but it's new xxd.
# Mac runner:     2022-01-14 new
if (XXD_VERSION LESS 2022)
  include(fail-xxd-old.cmake OPTIONAL)
endif()
# Tests that fail on a new version of xxd or no version string:
if (XXD_VERSION GREATER 2021 OR XXD_VERSION STREQUAL "")
  include(fail-xxd-new.cmake OPTIONAL)
endif()

message("Failing tests: ${FAILING_TESTS}")
message("Skipped tests: ${SKIP_TESTS}")

function(add_gold_tests TESTS TOIT_NAME UNIX_NAME)
  foreach(file ${${TESTS}})
    set(test_name "/tests/${file}")
    if("${test_name}" IN_LIST SKIP_TESTS)
      continue()
    endif()

    add_test(
      NAME "${test_name}"
      COMMAND "sh" "tests/gold-test.sh" ${TOITRUN} "tests/${file}" ${TOIT_NAME} ${UNIX_NAME}
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )

    set_tests_properties(${test_name} PROPERTIES TIMEOUT ${TEST_TIMEOUT})

    if ("${test_name}" IN_LIST FAILING_TESTS)
      set_tests_properties("${test_name}" PROPERTIES WILL_FAIL TRUE)
    endif()

  endforeach()
endfunction()

function(add_unix_tests TESTS TOIT_NAME UNIX_NAME)
  foreach(file ${${TESTS}})
    set(test_name "/tests/${file}")
    if("${test_name}" IN_LIST SKIP_TESTS)
      continue()
    endif()

    add_test(
      NAME "${test_name}"
      COMMAND "sh" "tests/compare-unix.sh" ${TOITRUN} "tests/${file}" ${TOIT_NAME} ${UNIX_NAME}
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )

    set_tests_properties(${test_name} PROPERTIES TIMEOUT ${TEST_TIMEOUT})

    if ("${test_name}" IN_LIST FAILING_TESTS)
      set_tests_properties("${test_name}" PROPERTIES WILL_FAIL TRUE)
    endif()

  endforeach()
endfunction()

add_gold_tests(XXXD_TESTS xxxd xxd)
add_unix_tests(UNIX_XXD_TESTS xxxd xxd)

add_gold_tests(TR_TESTS tr tr)
add_unix_tests(UNIX_TR_TESTS tr tr)
