# Copyright (C) 2023 Toitware ApS.
# Use of this source code is governed by a Zero-Clause BSD license that can
# be found in the tests/TESTS_LICENSE file.

# Append to FAILING_TESTS array:
list(APPEND FAILING_TESTS
  /tests/elide-zeros.options   # xxd needs a larger zero chunk before it starts using *.
  /tests/max-len.options       # We don't stop early when the max length is reached.
)
