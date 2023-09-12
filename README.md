# xxxd
An alternative to xxd.  Xxd is sometimes distributed with vim, whereas this is standalone.

A binary file to text converter.

It is particularly useful for converting a file into a format that can be understood
by a C compiler.

See the [Releases](releases/) area to download binaries for major OSs.

## Differences to xxd

* Long options must be used with double dashes, not single dashes.
* The single letter options are the same as xxd, but some long form options have been added:
    * `--compact` A more compact output format for C format.
    * `--indentation` Change the default indentation (2 for C format, 0 for other formats).
    * `--little-endian` An option that changes the endianness of multi-byte words without changing the format.
    * `--tabs` Use a mixture of tabs and spaces for indentation.
    * `--tab-width` Change the default tab width if tabs are used (8).
* Does not have a `-r` option to convert text back to binary. The `--seek` option is therefore also not supported.
* The `-c` (columns) option is not limited to 256.
* The `-E` (EBCDIC) option is not supported.
* The `-p` (postscript) option has only one long form option, `--postscript`.  The `--ps` and `--plain` aliases are not supported.
* The `-s` option does not accept unary plus, and negative seeks are not supported.

# Usage

```
Usage:
  xxxd [<options>] [--] [<in:file>] [<out:file>]

Options:
  -b, --bits                  Write bytes in binary format (default is hex)
  -c, --cols int              Max bytes per line
      --compact               Omit spaces between bytes, use decimal instead of hex.
  -g, --groupsize int         Number of bytes to group together
  -h, --help                  Show help for this command.
  -i, --include               Produce C include format
      --indentation int       Number of positions to indent by
  -l, --len int               Stop writing after len bytes
      --little-endian         Read the input data in little endian order
  -e, --little-endian-4-byte  4-byte words, read little endian order
  -n, --name string           Name of the variable to assign the data to (default: input filename)
  -o, --offset int            Add offset to the displayed byte position (default: 0)
  -p, --postscript            Use postscript format (no separators)
  -s, int                     Number of bytes to skip at the beginning (default: 0)
      --tab-width int         Number of spaces that a tab corresponds to (default: 8)
      --tabs                  Use tabs for indentation
  -u, --upper-case            Use upper case hex digits

Rest:
  in file   Input (default stdin)
  out file  Output (default stdout)
```
