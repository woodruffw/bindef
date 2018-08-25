`bindef` syntax
===============

As mentioned in the [README](README.md), `bindef` has two primary expressions: *commands* and
*pragmas*.

This page documents the default commands and all pragmas.

## Commands

`bindef` has commands for emitting integers, floating-point numbers, and strings.

All commands take a *value*. That value can be literal or a Ruby expression.

### Integers

The integer commands map directly to their `stdint.h` types: a `u8` is a `uint8_t`,
an `i64` is an `int64_t`, and so on.

```ruby
# Emits a uint8_t with the value 127.
u8 127

# Emits a int32_t with the value 0.
i32 0

# Produces a warning (negative value used with unsigned command), but still works.
u16 -100

# Produces an error (value too large for command).
i16 (2**32) - 1
```

### Floating-point numbers

There are two floating-point commands: `f32` for single-precision, and `f64` for double-precision.

```ruby
# Transparent promotion of an integer to a float.
f32 0

# Ruby floating-point constants work..
f64 Math::PI
f64 Float::INFINITY
```

### Strings

There is only one string command: `str`. `str` does *not* add a terminating NUL, a newline, or
anything else to the specified string.

```ruby
str "hello world!"

# Add a terminating NUL.
str "look ma, a C-string!\x00"

# Ruby's string interpolation works.
foo = "bar baz quux"
str "#{foo}!\n"
```

## Pragmas

Pragmas tell `bindef` *how* to emit commands. They tell commands what endianness they should
use, what encoding strings are in, and how loud to be about warnings and informational messages.

Pragmas are global settings, meaning that setting one will cause it to remain set until explicitly
changed to another value. This can be tedious to keep track of (and makes it easy to introduce
transposition bugs), so the `pragma` expression provides a block form:

```ruby
# Changes the verbosity setting to true, but only for the duration of the block.
pragma verbose: true do
  str "foo"
end
```

### `verbose`

Default: `false`.

Tells `bindef` how verbose to be. Verbose messages are prefixed with `V: ` and are logged to
`stderr`.

### `warnings`

Default: `true`.

Tells `bindef` whether or not to emit warnings, which are nonfatal (unlike errors). Warning
messages are prefixed with `W: ` and are logged to `stderr`.

```ruby
# Or use the block form above.
pragma warnings: false
u8 -127
pragma warnings: true
```

### `endian`

Default: `:little`.

Tells `bindef` which endianness to use when emitting integers and floats.

```ruby
pragma endian: :big
u16 0x00FF
u16 0xFF00
```

### `encoding`

Default: `"utf-8"`

Tells `bindef` how to encode the strings it emits via `str`.

```ruby
pragma encoding: "ascii"
str "this is a plain old ASCII string"

pragma encoding: "utf-8"
str "this👏is👏a👏utf-8👏string"

pragma encoding: "utf-32"
str "this is a waste of space"
```

`encoding` expects a lowercase string, and can take any of the
[encodings supported by Ruby](https://ruby-doc.org/core/Encoding.html#method-c-name_list).
