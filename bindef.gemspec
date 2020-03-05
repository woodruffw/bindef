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
  s.homepage              = "https://github.com/woodruffw/bindef"
  s.license               = "MIT"

  s.executables << "bd"

  s.add_development_dependency "rspec", "~> 3.8"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "yard", "~> 0.9.9"
end
