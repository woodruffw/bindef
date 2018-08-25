# frozen_string_literal: true

require_relative "lib/bindef/version"

Gem::Specification.new do |s|
  s.name                  = "bindef"
  s.version               = Bindef::VERSION
  s.summary               = "bindef - A DSL and command-line tool for generating binary files"
  s.authors               = ["William Woodruff"]
  s.email                 = "william@yossarian.net.com"
  s.files                 = Dir["LICENSE", "*.md", ".yardopts", "lib/**/*"]
  s.required_ruby_version = ">= 2.3.0"
  s.license               = "MIT"

  s.executables << "tn"

  s.add_development_dependency "yard", "~> 0.9.9"
end
