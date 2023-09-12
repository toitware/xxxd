# Copyright (C) 2023 Toitware ApS.
# Use of this source code is governed by a Zero-Clause BSD license that can
# be found in the tests/TESTS_LICENSE file.

set(FAILING_TESTS
  /tests/elide-zeros.options   # xxd needs a larger zero chunk before it starts using *.
  /tests/include-format-upper-case-hex.options # xxd upper cases the X in 0xAB, but only in C include format.
  /tests/little-endian.options # xxd inserts a space before the ASCII section in little endian mode.
  /tests/grouping-0.options    # Bug in xxxd.
  /tests/grouping-9.options    # We don't support groups of more than 64 bits.
  /tests/max-len.options       # We don't stop early when the max length is reached.
)
