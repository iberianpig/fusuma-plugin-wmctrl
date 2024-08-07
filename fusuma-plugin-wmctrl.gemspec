# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fusuma/plugin/wmctrl/version"

Gem::Specification.new do |spec|
  spec.name = "fusuma-plugin-wmctrl"
  spec.version = Fusuma::Plugin::Wmctrl::VERSION
  spec.authors = ["iberianpig"]
  spec.email = ["yhkyky@gmail.com"]

  spec.summary = "Wmctrl plugin for Fusuma "
  spec.description = "fusuma-plugin-wmctrl is Fusuma plugin for window manager."
  spec.homepage = "https://github.com/iberianpig/fusuma-plugin-wmctrl"
  spec.license = "MIT"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir["{bin,lib,exe}/**/*", "LICENSE*", "README*", "*.gemspec"]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.7"
  # https://packages.ubuntu.com/search?keywords=ruby&searchon=names&exact=1&suite=all&section=main
  # support focal (20.04LTS) 2.7
  spec.add_dependency "fusuma", ">= 3.1"
end
