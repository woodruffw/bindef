# frozen_string_literal: true

class Bindef
  module Extras
    # Potentially useful extra string emission commands.
    module String
      # Emits a null-terminated string.
      # @note Like {Bindef#str}, uses the `:encoding` {Bindef#pragma}
      # @param string [String] the string to emit
      # @return [void]
      # @example
      #  strz "foobar" # Emits "foobar\x00"
      def strz(string)
        str string
        str "\0"
      end

      # Emits a string, NUL-padded up to the given length in bytes.
      # @note Like {Bindef#str}, uses the `:encoding` {Bindef#pragma}
      # @param string [String] the string to emit
      # @param maxpad [Integer] the maximum number of padding NULs
      # @return [void]
      # @example
      #  strnz "foo", 5 # Emits "foo\x00\x00"
      def strnz(string, maxpad)
        pad = maxpad

        str string do |enc_string|
          pad = maxpad - enc_string.bytesize
        end

        raise CommandError, "maxpad < encoded string len" if pad.negative?

        # Reset our encoding temporarily, to make sure we emit the right number of NULs.
        pragma encoding: "utf-8" do
          str("\x00" * pad)
        end
      end

      # Emits a length-prefixed string.
      # @note Like {Bindef#str}, uses the `:encoding` {Bindef#pragma}
      # @note Like {Bindef#u16} and wider, the `:endian` {Bindef#pragma}
      # @param int_fmt [Symbol] the width of the length prefix, as one of the integer commands
      # @param string [String] the string to emit
      # @return [void]
      # @example
      #  lstr :u8, "foo" # Emits "\x03foo"
      def lstr(int_fmt, string)
        str string do |enc_string|
          send int_fmt, enc_string.bytesize
        end
      end
    end
  end

  include Extras::String
end
