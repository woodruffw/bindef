# frozen_string_literal: true

class Bindef # rubocop:disable Style/Documentation
  module Extras
    # Potentially useful TLV (tag-length-value) commands.
    #
    # Writing a single sufficiently generic TLV command without
    # really abusing Ruby's syntax is hard. Instead, we provide
    # specialized commands for empirically common TLV widths.
    module TLV
      # Emit a `uint8_t` type, a `uint8_t` length, and a value.
      # @param type [Integer] the type number
      # @param hsh [Hash] a mapping of `command => value`
      # @example
      #  tlv_u8 1, u32: 0xFF00FF00 # Emits: "\x01\x04\xFF\x00\xFF\x00"
      #  tlv_u8 2, str: "hello" # Emits: "\x02\x05hello"
      def tlv_u8(type, hsh)
        u8 type

        cmd, value = hsh.shift

        send cmd, value do |blob|
          u8 blob.bytesize
        end
      end

      # Emit a `uint16_t` type, a `uint16_t` length, and a value.
      # @param type [Integer] the type number
      # @param hsh [Hash] a mapping of `command => value`
      # @see tlv_u8
      def tlv_u16(type, hsh)
        u16 type

        cmd, value = hsh.shift

        send cmd, value do |blob|
          u16 blob.bytesize
        end
      end

      # Emit a `uint32_t` type, a `uint32_t` length, and a value.
      # @param type [Integer] the type number
      # @param hsh [Hash] a mapping of `command => value`
      # @see tlv_u8
      def tlv_u32(type, hsh)
        u32 type

        cmd, value = hsh.shift

        send cmd, value do |blob|
          u32 blob.bytesize
        end
      end
    end
  end

  include Extras::TLV
end
