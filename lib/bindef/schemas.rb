# frozen_string_literal: true

class Bindef
  # Schemas used to validate commands and pragmas throughout {Bindef}.
  module Schemas
    # A mapping of valid pragma keys to lists of valid pragma values.
    PRAGMA_SCHEMA = {
      verbose: [true, false],
      warnings: [true, false],
      endian: %i[big little],
      encoding: Encoding.name_list.map(&:downcase),
    }.freeze

    # The default pragma settings.
    DEFAULT_PRAGMAS = {
      verbose: false,
      warnings: true,
      endian: :little,
      encoding: "utf-8",
    }.freeze

    # A map of endianded integer commands to `Array#pack` formats.
    # @api private
    ENDIANDED_INTEGER_COMMAND_MAP = {
      u16: "S",
      u32: "L",
      u64: "Q",
      i16: "s",
      i32: "l",
      i64: "q",
    }.freeze
  end
end
