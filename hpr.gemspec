# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hpr/version'

Gem::Specification.new do |spec|
  spec.name          = "hpr"
  spec.version       = Hpr::VERSION
  spec.authors       = ["Cristian Rasch", "Roger Kind Kristiansen"]
  spec.email         = ["cristianrasch@fastmail.fm", "roger@legelisten.no"]
  spec.summary       = %q{Ruby wrapper for Helsepersonellregisteret (HPR).}
  spec.homepage      = "https://github.com/legelisten/hpr/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "nokogiri"
  spec.add_runtime_dependency "mechanize"

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3"
  spec.add_development_dependency "webmock"
end
