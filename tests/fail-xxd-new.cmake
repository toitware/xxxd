# Copyright (C) 2023 Toitware ApS.
# Use of this source code is governed by a Zero-Clause BSD license that can
# be found in the tests/TESTS_LICENSE file.

# Append to FAILING_TESTS.
list(APPEND FAILING_TESTS
  /tests/little-endian.options  # New xxd adds an extra space for no reason.
  /tests/little-endian-grouping-8.options  # New xxd adds an extra space for no reason.
  /tests/little-endian-grouping-16.options  # New xxd adds an extra space for no reason.
)
