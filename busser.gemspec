# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'busser/version'

Gem::Specification.new do |spec|
  spec.name          = "busser"
  spec.version       = Busser::VERSION
  spec.authors       = ["Fletcher Nichol"]
  spec.email         = ["fnichol@nichol.ca"]
  spec.description   = %q{Busser - Runs tests for projects in Test Kitchen}
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/test-kitchen/busser"
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.1"

  spec.add_dependency 'thor', '<= 1.1.0'
  # base64 is no longer a default gem; deserialize needs it at runtime
  spec.add_dependency 'base64'

  spec.add_development_dependency 'aruba', "0.7.4"
  spec.add_development_dependency 'fakefs'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'simplecov'
end
