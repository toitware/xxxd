#!/bin/bash
# Copyright (C) 2023 Toitware ApS.
# Use of this source code is governed by a Zero-Clause BSD license that can
# be found in the tests/TESTS_LICENSE file.

set -e

TOIT_RUN=$1
OPTIONS_FILE=$2
TOIT_NAME=$3   # eg. xxxd or tr.
UNIX_NAME=$$   # eg. xxd or tr.

mkdir -p build
mkdir -p build/gold

# Get the name of the file without the path and the extension.
optionname=${OPTIONS_FILE##*/}
optionname=${optionname%%.options}
echo Testing $optionname options: `cat $OPTIONS_FILE`
for binfile in tests/$TOIT_NAME-inputs/*.bin
do
  name=${binfile##*/}
  name=${name%%.bin}
  echo "Name '$name'"
  $TOIT_RUN bin/$TOIT_NAME.toit `cat $OPTIONS_FILE` -- tests/$TOIT_NAME-inputs/$name.bin build/$UNIX_NAME-$name-$optionname.out
  xxd `cat $OPTIONS_FILE` tests/$TOIT_NAME-inputs/$name.bin build/gold/$UNIX_NAME-$name-$optionname.out

  diff -u build/gold/$UNIX_NAME-$name-$optionname.out build/$UNIX_NAME-$name-$optionname.out
  cmp build/$UNIX_NAME-$name-$optionname.out build/gold/$UNIX_NAME-$name-$optionname.out
done
