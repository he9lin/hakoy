# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hakoy/version'

Gem::Specification.new do |spec|
  spec.name          = "hakoy"
  spec.version       = Hakoy::VERSION
  spec.authors       = ["Lin He"]
  spec.email         = ["he9lin@gmail.com"]
  spec.summary       = %q{Parse and organize data into timestamp-sliced directories.}
  spec.description   = %q{Parse and organize data into timestamp-sliced directories.}
  spec.homepage      = "https://github.com/he9lin/hakoy"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "chronic", "~> 0.10.2"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14.1"
  spec.add_development_dependency "guard-rspec"
end
