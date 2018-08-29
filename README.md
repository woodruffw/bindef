bindef
========

[![Gem Version](https://badge.fury.io/rb/bindef.svg)](https://badge.fury.io/rb/bindef)
[![Build Status](https://travis-ci.org/woodruffw/bindef.svg?branch=master)](https://travis-ci.org/woodruffw/bindef)
[![Coverage Status](https://codecov.io/gh/woodruffw/bindef/branch/master/graph/badge.svg)](https://codecov.io/gh/woodruffw/bindef)

`bindef` is a DSL and command-line tool for building binary files.

It's inspired by [t2b](https://github.com/thosakwe/t2b), but with a few crucial differences:

* `bindef` scripts run within a Ruby process, making the DSL a strict superset of Ruby
* Support for different (and multiple!) endians, string encodings, etc, is baked into the language
* Reports common mistakes loudly as warnings (or errors, if severe enough)
* Comes with a collection of user-selectable extensions for common binary formats (TLVs, control
codes, etc.)

## Syntax

`bindef`'s syntax is stream-oriented, with two primary expressions: commands and pragmas.

Commands cause `bindef` to emit data, while pragmas influence *how* commands act.

Here's a simple `bindef` script that emits a unsigned 32-bit integer twice, in different endians:

```ruby
# `bindef` starts in little-endian, so this is redundant
pragma endian: :little

u32 0xFF000000

# or `pragma :endian => :big`, if you prefer
pragma endian: :big

u32 0xFF000000
```

The [example directory](example/) has more. Read the [SYNTAX](SYNTAX.md) file for a
complete listing of commands and pragmas.

## Installation

`bindef` is available via RubyGems:

```bash
$ gem install bindef
$ bd -h
```

You can also run it directly from this repository:

```bash
$ ruby -Ilib ./bin/bd -h
```

## Usage

In general, running a `bindef` script is as simple as:

```bash
$ bd < path/to/input.bd > path/to/output.bin
```

or:

```bash
$ bd -i path/to/input.bd -o /path/to/output.bin
```

You can also choose to enable one or more *extra* command sets via the `-e`, `--extra` flag:

```bash
# extra commands for building TLVs
$ bd -e tlv < input.bd > output.bin

# extra commands for ASCII control codes and string manipulation
$ bd -e ctrl,string < input.bd > output.bin
```

## Design goals

`bindef` should...

* ...have no runtime dependencies other than the current stable Ruby
* ...be easy to read, even without knowledge of Ruby's syntax
* ...be easy to write, even without knowledge of Ruby's syntax
* ...be easy for other programs to emit without being (too) aware of Ruby's syntax
* ...be easy to debug, with warnings and errors for common mistakes (overflows, negative
unsigned integers, etc.)
