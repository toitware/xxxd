#!/bin/bash
# Copyright (C) 2023 Toitware ApS.
# Use of this source code is governed by a Zero-Clause BSD license that can
# be found in the tests/TESTS_LICENSE file.

set -e

TOIT_RUN=$1
OPTIONS_FILE=$2

mkdir -p build
mkdir -p build/gold

# Get the name of the file without the path and the extension.
optionname=${OPTIONS_FILE##*/}
optionname=${optionname%%.options}
echo Testing $optionname options: `cat $OPTIONS_FILE`
for binfile in tests/*.bin
do
  name=${binfile##*/}
  name=${name%%.bin}
  echo "Name '$name'"
  $TOIT_RUN bin/xxxd.toit `cat $OPTIONS_FILE` -- tests/$name.bin build/$name-$optionname.dump
  xxd `cat $OPTIONS_FILE` tests/$name.bin build/gold/$name-$optionname.dump

  diff -u build/gold/$name-$optionname.dump build/$name-$optionname.dump
  cmp build/$name-$optionname.dump build/gold/$name-$optionname.dump
done
