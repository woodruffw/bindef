# frozen_string_literal: true

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start do
    add_filter "spec/"
  end
end

require "rspec"

require "bindef"

# Helper methods for specs.
module Helpers
  def bindef(input = nil, verbose: false, warnings: true)
    output = StringIO.new
    error = StringIO.new

    bd = Bindef.new(output, error, verbose: verbose, warnings: warnings)
    bd.instance_eval input if input

    yield bd if block_given?

    output.rewind
    error.rewind

    [bd, output.read.b, error.read.b]
  end
end

RSpec.configure do |config|
  config.include Helpers
end
