# ≈ JBOL ≈

**JBOL** is a collection of modules and tools for the **JQ** language.

`jq` is a lightweight and flexible command-line JSON processor, and to use
`jq` you must program in the **JQ** language, a lazy functional language with an evaluation
model similar to the _goal-directed style_ of **SNOBOL** and **Icon** languages.
If you are interested in **JBOL** you can also see [_jqt_](https://fadado.github.io/jqt/),
a related project offering a template engine implemented on top of `jq`.

The name **JBOL** has been chosen to honor the inspirational **SNOBOL** influence.

## Modules

All **JBOL** modules reside in the `fadado.github.io` directory

## Tools

Thin _Bash_ wrappers around **JQ** filters:

### jgen

`jgen` generates JSON schemas for instance documents.

### jval

`jval` validates instance documents against a JSON [schema](http://json-schema.org/).
`jval` supports the entire JSON schema draft v4 specification, except for
remote references. It&rsquo;s tested against the official
[JSON-Schema-Test-Suite](https://github.com/json-schema-org/JSON-Schema-Test-Suite),
and the only failed tests are in the files `definitions.json`, `ref.json` and `refRemote.json`.

Some of the `jval` limitations are:

* Remote references are not supported.
* Schema-reference resolution does not check recursivity: if there is a nested
  cross-schema reference, it will not stop.
* Some checks for the `format` keyword are not very accurate or consider valid any non empty string.
* Errors cannot reference exactly the line where are produced.

## Installation

If you have the latests _GNU Make_ tool in your system run this command:

```
$ sudo make install
```

This will install modules and other data files to `/usr/local/share/jbol`, and
tools to `/usr/local/bin`.

### Manual installation

All provided modules are in the `fadado.github.io` directory. Copy this
directory to the top-level **JQ** modules path with commands equivalent to:

```sh
$ sudo mkdir -p /usr/local/share/jbol
$ sudo cp -r fadado.github.io /usr/local/share/jbol
```

The tools and related schema files can be installed with commands equivalent
to:

```sh
$ sudo mkdir -p /usr/local/bin
$ sudo cp bin/* /usr/local/bin
$ sudo cp -r schemata /usr/local/share/jbol
```

**Warning**: if you do not use `/usr/local/bin` for the script some harcoded
pathnames must be edited!

## Usage

In your **JQ** scripts include or import modules with directives like

```jq
import "fadado.github.io/string" as str;
import "fadado.github.io/string/regexp" as re;
```

and then use the modules services in your code:

```jq
def remove_digits($s):
    $s | str::translate("01234567890"; "")
;
def normalize_space($s):
    $s | [re::split] | str::join(" ")
;
```

Finally, run your script with the `jq` appropriated `-L` option:

```sh
$ jq -L/usr/local/share/jbol -f script.jq
```

To use the tools ask first for help:

```
$ jgen --help
jgen -- Generates JSON schemas for instance documents

Usage: jgen [-h | --help | -v | --version]
       jgen [options...] [files...]

jgen generates a JSON schema for each instance document read from the
standard input.  One or more files may be specified, in which case jgen will
read input from those instead.

Options:
    -a, --verbose-array     Add array constraints
    -c, --compact           Compact output
    -h, --help              Show this help
    -k, --sort-keys         Sort output keys 
    -n, --verbose-number    Add number constraints
    -o, --verbose-object    Add object constraints
    -r, --required          Add the 'required' keyword
    -s, --verbose-string    Add string constraints
    -v, --version           Print version information
```

```
$ jval --help
jval -- Validates instance documents against a JSON schema

Usage: jval [-h | --help | -v | --version]
       jval [options...] schema [file...]

jval validates against an schema a JSON instance document read from the
standard input.  One or more files may be specified, in which case jval will
read input from those instead.

Options:
    -h, --help              Show this help
    -q, --quiet             Suppress all normal output (status is zero or one)
    -s, --schema            Validates a JSON schema against the Schema meta-schema
    -v, --version           Print version information
    -y, --hyper             Validates a JSON schema against the Hyper-Schema meta-schema
```

## Tests end examples

The `Makefile` has rules to help you run the tests included in the `tests`
directory.  To run all tests simply execute `make`, or `make check` to force
the execution, again, of previously successful tests.

Several **JQ** scripts are included in the `examples` directory.  The `Makefile` has
rules to help you run the examples, but you should study first the code to know
how each example works. Warning: the scripts expect `jq` to be at `/usr/local/bin`.

As an example, this script generates in a smart way the solutions for the
classical _8 queens_ problem:

```
#!/usr/local/bin/jq -cnRrf

include "fadado.github.io/prelude";

# Smart N-Queens

def queens($n; $columns):
    def safe($i; $j):
        every(
            range($i) as $k
            | .[$k] as $l
            | (($i-$k)|fabs) != (($j-$l)|fabs)
        )
    ;
    def available_columns:
        . as $board
        | $columns - $board
    ;
    def qput:
        length as $row
        | if $row == $n # assert(available_columns == [])
          then . # one solution found
          else
            available_columns[] as $column
            | select(safe($row; $column))
            | .[$row]=$column
            | qput
          end
    ;
    #
    [] | qput
;

8 as $N | queens($N; [range($N)])

# vim:ai:sw=4:ts=4:et:syntax=jq
```

<!--
vim:syntax=markdown:et:ts=4:sw=4:ai
-->
