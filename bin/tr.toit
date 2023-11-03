// Copyright (C) 2023 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import cli
import host.pipe
import host.file
import reader show BufferedReader
import tr
import .version

main args:
  if args.size == 1 and args[0] == "--version" or args[0] == "-v":
    print "tr $XXXD_VERSION"
    return
  root-cmd := cli.Command "tr"
      --long-help="""
          Translate or delete characters in a text stream.
          Options are largely compatible with the tr utility from Unix.
          The -C alias for the -c option is not supported.
          Non-ASCII characters are normally passed through unchanged, but
            can be deleted when using -d -c and their replacements are
            squeezed like other characters.  They cannot be specified
            explicitly in the set1 and set2 arguments.
          """
      --options=[
          cli.Flag "complement"
              --default=false
              --short-name="c"
              --short-help="Use the complement of the first set of characters",
          cli.Flag "delete"
              --default=false
              --short-name="d"
              --short-help="Delete the characters in the first set, no translation",
          cli.Flag "squeeze-repeats"
              --default=false
              --short-name="s"
              --short-help="Replace each occurrence of a repeated character that is listed in the second set with a single occurrence of that character",
          cli.Flag "version"
              --short-name="v"
              --default=false
              --short-help="Print version and exit",
          cli.Option "in"
              --default=""
              --short-name="i"
              --short-help="Input file (default stdin)",
          cli.Option "out"
              --default=""
              --short-name="o"
              --short-help="Output file (default stdout)",
          ]
      --rest=[
          cli.Option "set1"
              --required
              --short-help="Set 1",
          cli.Option "set2"
              --default=""
              --short-help="Set 2"
          ]
      --run= :: translate it
  root-cmd.run args

translate parsed -> none:
  if parsed["version"]:
    print "tr $XXXD_VERSION"
    return

  set1/string := parsed["set1"]
  set2/string? := parsed["set2"]
  if set1.size != (set1.size --runes):
    throw "set1 must be ASCII only"
  if set2.size != (set2.size --runes):
    throw "set2 must be ASCII only"

  if set2 == "": set2 = null

  if parsed["delete"]:
    if set2:
      throw "cannot use -d and also specify set2"
  else:
    if not set2:
      throw "must specify set2 when not using -d"

  t := tr.Translator
      --complement=parsed["complement"]
      --squeeze=parsed["squeeze-repeats"]
      --delete=parsed["delete"]
      set1
      set2

  in-name := parsed["in"]
  out-name := parsed["out"]

  reader := BufferedReader
      in-name == "" ?
        pipe.stdin :
        file.Stream.for-read in-name

  writer := out-name == ""
    ? pipe.stdout
    : file.Stream.for-write out-name

  while data := reader.read:
    translated := t.tr data
    writer.write translated
