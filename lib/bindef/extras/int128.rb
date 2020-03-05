# frozen_string_literal: true

class Bindef # rubocop:disable Style/Documentation
  module Extras
    # Potentially useful 128-bit integer emission commands.
    module Int128
      # Emits a `__uint128_t`.
      # @note Uses the `:endian` {Bindef#pragma}
      # @param num [Integer] the number to emit
      # @return [void]
      def u128(num)
        upper = num >> 64
        lower = num & (2**64 - 1)

        if pragmas[:endian] == big
          u64 upper
          u64 lower
        else
          u64 lower
          u64 upper
        end
      end

      # Emits a `__int128_t`.
      # @note Uses the `:endian` {Bindef#pragma}
      # @param num [Integer] the number to emit
      # @return [void]
      def i128(num)
        upper = num >> 64
        lower = num & (2**64 - 1)

        if pragmas[:endian] == big
          i64 upper
          u64 lower
        else
          u64 lower
          i64 upper
        end
      end
    end
  end

  include Extras::Int128
end
