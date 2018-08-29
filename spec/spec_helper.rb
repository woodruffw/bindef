# frozen_string_literal: true

require "rspec"

require "bindef"

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start

  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

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
