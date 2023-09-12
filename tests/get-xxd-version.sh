#!/bin/bash
# Copyright (C) 2023 Toitware ApS.
# Use of this source code is governed by a Zero-Clause BSD license that can
# be found in the tests/TESTS_LICENSE file.

set -e

xxd -v

# Note that `xxc -v` outputs the format: "xxd 2021-07-07 ...
# We only care about the date, so we use awk to extract that.
xxd -v 2>&1 | awk '{print $2}'
