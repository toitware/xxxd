#!/bin/bash
# Copyright (C) 2023 Toitware ApS.
# Use of this source code is governed by a Zero-Clause BSD license that can
# be found in the tests/TESTS_LICENSE file.

set -e

TOIT_RUN=$1
OPTIONS_FILE=$2
TOIT_NAME=$3   # eg. xxxd or tr.
UNIX_NAME=$4   # eg. xxd or tr.

mkdir -p build
mkdir -p build/gold

# Get the name of the file without the path and the extension.
optionname=${OPTIONS_FILE##*/}
optionname=${optionname%%.options}
OPTIONS=`cat $OPTIONS_FILE`
echo Testing $optionname options: $OPTIONS
for binfile in tests/$TOIT_NAME-inputs/*.bin
do
  name=${binfile##*/}
  name=${name%%.bin}
  echo "Name '$name'"
  in_file=tests/$TOIT_NAME-inputs/$name.bin
  toit_out_file=build/$TOIT_NAME-$name-$optionname.out
  unix_out_file=build/gold/$UNIX_NAME-$name-$optionname.out
  if [[ "$OPTIONS" == *"%input"* ]]; then
    OPTIONS_WITH_INPUT="${OPTIONS//%input/$in_file}"
    TOIT_OPTIONS_WITH_FILES="${OPTIONS_WITH_INPUT//%output/$toit_out_file}"
    UNIX_OPTIONS_WITH_FILES="${OPTIONS_WITH_INPUT//%output/$unix_out_file}"
  else
    TOIT_OPTIONS_WITH_FILES="$OPTIONS -- $in_file $toit_out_file"
    UNIX_OPTIONS_WITH_FILES="$OPTIONS $in_file $unix_out_file"
  fi
  bash -c "$TOIT_RUN bin/$TOIT_NAME.toit $TOIT_OPTIONS_WITH_FILES"
  bash -c "$UNIX_NAME $UNIX_OPTIONS_WITH_FILES"

  diff -u build/gold/$UNIX_NAME-$name-$optionname.out build/$TOIT_NAME-$name-$optionname.out
  cmp build/$TOIT_NAME-$name-$optionname.out build/gold/$UNIX_NAME-$name-$optionname.out
done
