#!/bin/bash
# Copyright (C) 2023 Toitware ApS.
# Use of this source code is governed by a Zero-Clause BSD license that can
# be found in the tests/TESTS_LICENSE file.

set -e

TOIT_RUN=$1
OPTIONS_FILE=$2

mkdir -p build

# Get the name of the file without the path and the extension.
optionname=${OPTIONS_FILE##*/}
optionname=${optionname%%.xxxd-options}
mkdir -p tests/gold/$optionname
mkdir -p build/$optionname
echo Testing $optionname options: `cat $OPTIONS_FILE`
exitvalue=0
for binfile in tests/*.bin
do
  name=${binfile##*/}
  name=${name%%.bin}
  echo "Name '$name'"
  $TOIT_RUN bin/xxxd.toit `cat $OPTIONS_FILE` -- tests/$name.bin build/$optionname/$name.dump

  if [ ! -f tests/gold/$optionname/$name.dump ]; then
    echo "No file: tests/gold/$optionname/$name.dump"
    exitvalue=1
  else
    diff -u tests/gold/$optionname/$name.dump build/$optionname/$name.dump
    cmp tests/gold/$optionname/$name.dump tests/gold/$optionname/$name.dump
  fi
done

exit $exitvalue
