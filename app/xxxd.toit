// Copyright (C) 2023 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import binary show LITTLE_ENDIAN BIG_ENDIAN
import cli
import host.pipe
import host.file
import reader show BufferedReader

main args:
  root-cmd := cli.Command "convert"
      --long-help="""
          Convert a binary file to a source code file.
          Options are largely compatible with the xxd utility from vim.
          The 'r' (reverse) command is not supported.
          """
      --options=[
          cli.Flag "autoskip"
              --default=false
              --short-name="a"
              --short-help="Replace blocks of zeros with '*'",
          cli.Flag "compact"
              --default=false
              --short-help="Omit spaces between bytes, use decimal",
          cli.Flag "little-endian-4-byte"
              --default=false
              --short-name="e"
              --short-help="Write 4-byte words in little endian order",
          cli.Flag "little-endian"
              --default=false
              --short-help="Read the input data in little endian order",
          cli.Flag "bits"
              --default=false
              --short-name="b"
              --short-help="Write bytes in binary format",
          cli.Flag "capitalize"
              --default=false
              --short-name="C"
              --short-help="Capitalize the variable names in C include format",
          cli.Flag "include"
              --default=false
              --short-name="i"
              --short-help="Produce C include format",
          cli.Flag "upper-case"
              --default=false
              --short-name="u"
              --short-help="Use upper case hex digits",
          cli.Flag "postscript"
              --default=false
              --short-name="p"
              --short-help="Use postscript format (no separators)",
          cli.Flag "tabs"
              --default=false
              --short-help="Use tabs for indentation",
          cli.Flag "version"
              --short-name="v"
              --default=false
              --short-help="Print version and exit",
          cli.Option "name"
              --short-name="n"
              --default=""
              --short-help="Name of the variable to assign the data to",
          cli.OptionInt "seek-input"
              --short-name="s"
              --default=0
              --short-help="Number of bytes to skip at the beginning",
          cli.OptionInt "offset"
              --short-name="o"
              --default=0
              --short-help="Add offset to the displayed byte position",
          cli.OptionInt "len"
              --short-name="l"
              --default=0
              --short-help="Stop writing after len bytes",
          cli.OptionInt "cols"
              --short-name="c"
              --default=-1
              --short-help="Max bytes per line",
          cli.OptionInt "groupsize"
              --short-name="g"
              --default=0
              --short-help="Number of bytes to group together",
          cli.OptionInt "indentation"
              --default=-1
              --short-help="Number of positions to indent by",
          cli.OptionInt "tab-width"
              --default=8
              --short-help="Number of spaces that a tab corresponds to",
          ]
      --rest=[
          cli.Option "in"
              --default=""
              --short-help="Input (default stdin)"
              --type="file",
          cli.Option "out"
              --default=""
              --short-help="Output (default stdin)"
              --type="file",
          ]
      --run= :: convert it
  root-cmd.run args

convert parsed -> none:
  if parsed["version"]:
    print "xxxd v0.1.0"
    return

  c := Convert parsed
  c.dump parsed

class Convert:
  line-start/LineStart
  word-formatter/WordFormatter
  separator/Separator
  trailer/Trailer

  auto-skip/bool
  declaration-allowed/bool := false
  little-endian/bool
  compact/bool ::= false
  group-size/int
  upper-case/bool
  cols/int

  constructor parsed:
    auto-skip = parsed["autoskip"]
    line-start = Offset parsed["offset"]
    word-formatter = RawHexFormatter parsed["upper-case"]
    separator = SpaceSeparator
    trailer = PrintableTrailer
    little-endian = parsed["little-endian"]
    if parsed["little-endian-4-byte"]:
      group-size = 4
      cols = 16
      if parsed["little-endian"] == null:
        little-endian = true
    else if parsed["bits"]:
      group-size = 1
      cols = 6
      word-formatter = BinaryFormatter
    else if parsed["include"]:
      declaration-allowed = true
      group-size = 1
      cols = 12
      line-start = Indentation --default-indentation=2 parsed["indentation"] parsed["tab-width"] parsed["tabs"]
      if parsed["compact"]:
        word-formatter = CompactFormatter
        separator = CompactCommaSeparator
      else:
        word-formatter = CFormatter parsed["upper-case"]
        separator = CommaSeparator
      trailer = NullTrailer
    else if parsed["postscript"]:
      group-size = 1
      cols = 30
      line-start = Indentation --default-indentation=0 parsed["indentation"] parsed["tab-width"] parsed["tabs"]
      separator = NullSeparator
      trailer = NullTrailer
    else:
      group-size = 2
      cols = 16

    if parsed["groupsize"] != 0:
      group-size = parsed["groupsize"]

    if parsed["cols"] != -1:
      cols = parsed["cols"]
    if cols == 0:
      cols = int.MAX

    if parsed["compact"]:
      compact = true

    compact = parsed["compact"]
    upper-case = parsed["upper-case"]

  dump parsed:
    in-name := parsed["in"]
    out-name := parsed["out"]

    normal-size := (line-start.next 0).size
    if cols != int.MAX:
      repeats := cols / group-size
      rest := cols % group-size
      repeats.repeat:
        normal-size += (word-formatter.format 0 --chunk=group-size).size
        last-in-line := rest == 0 and it == repeats - 1
        normal-size += (separator.next --last-in-line=last-in-line --last-in-file=false).size
      if rest != 0:
        normal-size += (word-formatter.format 0 --chunk=rest).size
        normal-size += (separator.next --last-in-line=true --last-in-file=false).size

    reader := BufferedReader
        in-name == "" ?
          pipe.stdin :
          file.Stream.for-read in-name

    name := ""
    if in-name != "":
      name = in-name
    if parsed["name"] != "":
      name = parsed["name"]
    if name != "":
      ba := name.to-byte-array
      ba.size.repeat:
        c := ba[it]
        if not 'a' <= c <= 'z' and not 'A' <= c <= 'Z' and not '0' <= c <= '9' and not c == '_':
          ba[it] = '_'
      name = ba.to-string
    if name != "" and '0' <= name[0] <= '9':
      name = "__$name"
    if parsed["capitalize"]:
      name = name.to-ascii-upper

    writer := out-name == ""
      ? pipe.stdout
      : file.Stream.for-write out-name

    if declaration-allowed and name != "":
      writer.write "unsigned char $(name)[] = {\n"

    in-all-zero := false
    all-zero-printed := false

    seek-input := parsed["seek-input"]
    if seek-input < 0: throw "-s options must be non-negative"
    reader.skip seek-input
    pos := seek-input

    while reader.can-ensure 1:
      bytes/int := ?
      if reader.can-ensure cols:
        bytes = cols
      else:
        bytes = reader.buffered
      data := reader.bytes bytes
      reader.skip bytes
      line := [line-start.next pos]
      pos += bytes
      last-line := not reader.can-ensure 1
      if not last-line and auto-skip:
        all-zero := true
        for i := data.size - 1; i >= 0; i--:
          if data[i] != 0:
            all-zero = false
            break
        if all-zero:
          if in-all-zero:
            if not all-zero-printed:
              all-zero-printed = true
              writer.write "*\n"
            continue
          else:
            in-all-zero = true
            all-zero-printed = false
        else:
          in-all-zero = false
          
      for i := 0; i < data.size; i += group-size:
        chunk := min (data.size - i) group-size
        word := (little-endian ? LITTLE_ENDIAN : BIG_ENDIAN).read-uint data chunk i
        last-in-line := i + group-size >= data.size
        line.add
            word-formatter.format word --chunk=chunk
        line.add
            separator.next --last-in-line=last-in-line --last-in-file=(last-in-line and last-line)
      line-string := line.join ""
      if trailer.align:
        line-string = line-string.pad --right normal-size
      writer.write "$line-string$(trailer.next data --last=(reader.can-ensure 1))\n"

    if declaration-allowed and name != "":
      suffix := parsed["capitalize"] ? "_LEN" : "_len"
      writer.write "};\nunsigned int $name$suffix = $pos;\n"


interface LineStart:
  next byte-offset/int -> string

class Offset implements LineStart:
  start/int

  constructor .start:

  next byte-offset/int -> string:
    return "$(%08x start + byte-offset): "

class Indentation implements LineStart:
  indentation/int
  tab-width/int
  use-tabs/bool

  constructor --default-indentation/int indentation/int .tab-width .use-tabs:
    if indentation == -1:
      this.indentation = default-indentation
    else:
      this.indentation = indentation

  next byte-offset/int -> string:
    return "\t" * (indentation / tab-width) + " " * (indentation % tab-width)

interface Trailer:
  next bytes/ByteArray --last/bool -> string
  align -> bool

class PrintableTrailer implements Trailer:
  align -> bool: return true

  next bytes/ByteArray --last/bool -> string:
    result := ByteArray bytes.size:
      byte := bytes[it]
      32 <= byte <= 126 ? byte : '.'
    return "  $result.to-string"

class NullTrailer implements Trailer:
  align -> bool: return false
  next bytes/ByteArray --last/bool -> string:
    return ""

interface Separator:
  next --last-in-line/bool --last-in-file/bool -> string

class NullSeparator implements Separator:
  next --last-in-line/bool --last-in-file/bool -> string:
    return ""

class CommaSeparator implements Separator:
  next --last-in-line/bool --last-in-file/bool -> string:
    if last-in-file: return ""
    if last-in-line: return ","
    return ", "

class CompactCommaSeparator implements Separator:
  next --last-in-line/bool --last-in-file/bool -> string:
    if last-in-file: return ""
    return ","

class SpaceSeparator implements Separator:
  next --last-in-line/bool --last-in-file/bool -> string:
    if last-in-line: return ""
    return " "

interface WordFormatter:
  format word/int --chunk/int -> string

abstract class FormatFormatter implements WordFormatter:
  format-string/string? := null
  format-letter/string := ?
  chars-per-byte/int := ?
  group-size/int := 0

  constructor .format-letter .chars-per-byte:

  format word/int --chunk/int -> string:
    fmt/string := ?
    if chunk == group-size:
      fmt = format-string
    else:
      fmt = "0$(chunk * chars-per-byte)$format-letter"
      format-string = fmt  // Cache it.
    return string.format fmt word

class BinaryFormatter extends FormatFormatter:
  constructor:
    super "b" 8

class RawHexFormatter extends FormatFormatter:
  constructor upper-case:
    super (upper-case ? "X" : "x") 2

class CompactFormatter implements WordFormatter:
  format word/int --chunk/int -> string:
    return word.stringify

class CFormatter extends RawHexFormatter:
  constructor upper-case/bool:
    super upper-case

  format word/int --chunk/int -> string:
    return "0x" + (super word --chunk=chunk)
