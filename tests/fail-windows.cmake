# Copyright (C) 2023 Toitware ApS.
# Use of this source code is governed by a Zero-Clause BSD license that can
# be found in the tests/TESTS_LICENSE file.

# The version of tr we compare against on Windows creates CRLF line endings
# which means they don't match the LF line endings we produce.  Since
# the inputs are LF files I feel our version is doing the right thing.

# Append to FAILING_TESTS.
list(APPEND FAILING_TESTS
  /tests/tr-unix/rot13.options
  /tests/tr-unix/keep-only-lower-case.options
  /tests/tr-unix/squash-vowels.options
  /tests/tr-unix/all-x.options
)
