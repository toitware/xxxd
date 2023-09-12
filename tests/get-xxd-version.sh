#!/bin/bash
# Copyright (C) 2023 Toitware ApS.
# Use of this source code is governed by a Zero-Clause BSD license that can
# be found in the tests/TESTS_LICENSE file.

# Note that `xxc -v` outputs the format: "xxd V1.10 27oct98 by Juergen Weigert"
# We only care about the year, so we use awk to extract that.
xxd -v 2>&1 | awk '{print $2}' | awk -F- '{print $1}'
