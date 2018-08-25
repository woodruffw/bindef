# frozen_string_literal: true

class Bindef
  module Extras
    # Helpers for {Extras::Ctrl}.
    module CtrlHelper
      # A sequential list of symbolic names for control codes.
      # @api private
      CONTROL_NAMES = %i[
        nul soh stx etx eot enq ack bel bs ht lf vt ff cr so si dle dc1 dc2 dc3 dc4 nak syn etb
        can em sub esc fs gs rs us
      ].freeze

      # A mapping of symbolic names for control codes to their numeric values.
      # @api private
      CONTROL_MAP = CONTROL_NAMES.zip(0x00..0x1F).to_h.freeze
    end

    # Potentially useful control character commands.
    module Ctrl
      CtrlHelper::CONTROL_MAP.each do |cmd, value|
        define_method cmd do
          u8 value
        end
      end
    end
  end

  include Extras::Ctrl
end
