# frozen_string_literal: true

require_relative "bindef/version"
require_relative "bindef/schemas"
require_relative "bindef/exceptions"

# The primary namespace for {Bindef}.
class Bindef
  include Bindef::Schemas

  # @return [Hash] the map of current pragma settings
  attr_reader :pragmas

  # @api private
  def initialize(output = $stdout, error = $stderr, verbose: false, warnings: true)
    @output = output
    @error = error
    @pragmas = DEFAULT_PRAGMAS.dup.update(verbose: verbose, warnings: warnings)
  end

  # Writes a message to the error I/O if verbose mode is enabled.
  # @note Uses the `:verbose` {#pragma}
  # @param msg [String] the message to write
  # @return [void]
  # @api private
  def verbose(msg)
    @error.puts "V: #{msg}" if @pragmas[:verbose]
  end

  # Writes a warning message to the error I/O.
  # @param msg [String] the warning message to write
  # @return [void]
  # @api private
  def warning(msg)
    @error.puts "W: #{msg}" if @pragmas[:warnings]
  end

  # Ensures that the given integer number can be represented within the given width of bits.
  # @param num [Integer] the number to test
  # @param width [Integer] the bit width to test against
  # @return [void]
  # @raise [CommandError] if the number is wider than `width` bits
  # @api private
  def validate_int_width!(num, width)
    raise CommandError, "width of #{num} exceeds #{width} bits" if num.bit_length > width
  end

  # Builds a string containing the given value packed into the given format.
  # @param value [Object] the value to emit
  # @param fmt [String] the `Array#pack` format to emit it in
  # @api private
  def blobify(value, fmt)
    [value].pack(fmt)
  end

  # Emits the given blob of data.
  # @param blob [String] the data to emit
  # @return [void]
  # @api private
  def emit(blob)
    @output << blob
  end

  # Captures unknown commands and raises an appropriate error.
  # @api private
  def method_missing(*args)
    raise CommandError, "unknown command: #{args.join(" ")}"
  end

  # @api private
  def respond_to_missing?(*_args)
    true
  end

  # Changes the values of the given pragma keys.
  # @see PRAGMA_SCHEMA
  # @param hsh [Hash] the keys and values to update the pragma state with
  # @yield [void] A temporary scope for the pragma changes, if a block is given
  # @return [void]
  # @example
  #  pragma verbose: true # changes the `:verbose` pragma to `true` for the remainder of the script
  #  pragma encoding: "utf-16" { str "foobar" } # changes the `:encoding` pragma for the block only
  def pragma(**hsh)
    old_pragmas = pragmas.dup

    hsh.each do |key, value|
      raise PragmaError, "unknown pragma: #{key}" unless @pragmas.key? key
      raise PragmaError, "bad pragma value: #{value}" unless PRAGMA_SCHEMA[key].include?(value)

      pragmas[key] = value
    end

    return unless block_given?

    yield
    pragmas.replace old_pragmas
  end

  # Emits a string.
  # @note Uses the `:encoding` {#pragma}
  # @param string [String] the string to emit
  # @return [void]
  def str(string)
    enc_string = string.encode pragmas[:encoding]
    blob = blobify enc_string, "a#{enc_string.bytesize}"

    yield blob if block_given?

    emit blob
  end

  # Emits a `float`.
  # @param num [Numeric] the number to emit
  # @return [void]
  def f32(num)
    # NOTE: All floats are double-precision in Ruby, so I don't have a good
    # (read: simple) way to validate single-precision floats yet.

    fmt = pragmas[:endian] == :big ? "g" : "e"
    blob = blobify num, fmt

    yield blob if block_given?

    emit blob
  end

  # Emits a `double`.
  # @param num [Numeric] the number to emit
  # @return [void]
  def f64(num)
    raise CommandError, "#{num} is an invalid double-precision float" if num.to_f.nan?

    fmt = pragmas[:endian] == :big ? "G" : "E"

    blob = blobify num, fmt

    yield blob if block_given?

    emit blob
  end

  # Emits a `uint8_t`.
  # @param num [Integer] the number to emit
  # @return [void]
  def u8(num)
    warning "#{num} in u8 command is negative" if num.negative?
    validate_int_width! num, 8

    blob = blobify num, "C"

    yield blob if block_given?

    emit blob
  end

  # Emits a `int8_t`.
  # @param num [Integer] the number to emit
  # @return [void]
  def i8(num)
    validate_int_width! num, 8

    blob = blobify num, "c"

    yield blob if block_given?

    emit blob
  end

  # @!method u16(num)
  #   Emits a `uint16_t`.
  #   @note Uses the `:endian` {#pragma}
  #   @param num [Integer] the number to emit
  #   @return [void]
  # @!method u32(num)
  #   Emits a `uint32_t`.
  #   @note Uses the `:endian` {#pragma}
  #   @param num [Integer] the number to emit
  #   @return [void]
  # @!method u64(num)
  #   Emits a `uint64_t`.
  #   @note Uses the `:endian` {#pragma}
  #   @param num [Integer] the number to emit
  #   @return [void]
  # @!method i16(num)
  #   Emits a `int16_t`.
  #   @note Uses the `:endian` {#pragma}
  #   @param num [Integer] the number to emit
  #   @return [void]
  # @!method i32(num)
  #   Emits a `int32_t`.
  #   @note Uses the `:endian` {#pragma}
  #   @param num [Integer] the number to emit
  #   @return [void]
  # @!method i64(num)
  #   Emits a `int64_t`.
  #   @note Uses the `:endian` {#pragma}
  #   @param num [Integer] the number to emit
  #   @return [void]
  ENDIANDED_INTEGER_COMMAND_MAP.each do |cmd, fmt|
    define_method cmd do |num, &block|
      warning "#{num} in #{cmd} command is negative" if num.negative? && cmd[0] == "u"
      validate_int_width! num, cmd[1..-1].to_i

      end_fmt = pragmas[:endian] == :big ? "#{fmt}>" : "#{fmt}<"

      blob = blobify num, end_fmt

      # Fun fact: You can't use `yield` in `define_method`.
      block&.call(blob)

      emit blob
    end
  end
end
