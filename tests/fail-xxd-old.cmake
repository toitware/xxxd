# Copyright (C) 2023 Toitware ApS.
# Use of this source code is governed by a Zero-Clause BSD license that can
# be found in the tests/TESTS_LICENSE file.

# Append to FAILING_TESTS.
list(APPEND FAILING_TESTS
  /tests/xxd-unix/include-format-funky-name.options             # -n option is new.
  /tests/xxd-unix/include-format-funky-name-upper-case.options  # -n option is new.
  /tests/xxd-unix/include-format-numeric-name.options           # -n option is new.
  /tests/xxd-unix/include-format-very-funky-name.options        # -n option is new.
  /tests/xxd-unix/little-endian-grouping-4-columns-6.options    # xxd's Alignment of the ASCII section is borked.
)
