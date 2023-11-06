#!/bin/bash
# Copyright (C) 2023 Toitware ApS.
# Use of this source code is governed by a Zero-Clause BSD license that can
# be found in the tests/TESTS_LICENSE file.

set -e

TOIT_RUN=$1
OPTIONS_FILE=$2
TOIT_NAME=$3
UNIX_NAME=$4

mkdir -p build

# Get the name of the file without the path and the extension.
optionname=${OPTIONS_FILE##*/}
optionname=${optionname%%.$TOIT_NAME-options}
mkdir -p tests/gold/$TOIT_NAME-$optionname
mkdir -p build/$TOIT_NAME-$optionname
OPTIONS=$(cat $OPTIONS_FILE)
echo Testing $optionname options: $OPTIONS
exitvalue=0
for binfile in tests/$TOIT_NAME-inputs/*.bin
do
  name=${binfile##*/}
  name=${name%%.bin}
  echo "Name '$name'"
  in_file=tests/$TOIT_NAME-inputs/$name.bin
  out_file=build/$TOIT_NAME-$optionname/$name.out
  if [[ "$OPTIONS" == *"%input"* ]]; then
# Substitute %input with $in_file:
    OPTIONS_WITH_INPUT="${OPTIONS//%input/$in_file}"
    OPTIONS_WITH_FILES="${OPTIONS_WITH_INPUT//%output/$out_file}"
  else
    OPTIONS_WITH_FILES="$OPTIONS -- $in_file $out_file"
  fi
  echo $TOIT_RUN bin/$TOIT_NAME.toit $OPTIONS_WITH_FILES
  $TOIT_RUN bin/$TOIT_NAME.toit $OPTIONS_WITH_FILES

  if [ ! -f tests/gold/$TOIT_NAME-$optionname/$name.out ]; then
    echo "No file: tests/gold/$TOIT_NAME-$optionname/$name.out"
    exitvalue=1
  else
    diff -u tests/gold/$TOIT_NAME-$optionname/$name.out build/$TOIT_NAME-$optionname/$name.out
    cmp tests/gold/$TOIT_NAME-$optionname/$name.out tests/gold/$TOIT_NAME-$optionname/$name.out
  fi
done

exit $exitvalue
