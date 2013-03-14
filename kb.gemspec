# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kb/version'

Gem::Specification.new do |spec|
  spec.name          = "kb"
  spec.version       = KB::VERSION
  spec.authors       = ["Fletcher Nichol"]
  spec.email         = ["fnichol@nichol.ca"]
  spec.description   = %q{Kitchen Busser - Runs tests for projects in test-kitchen}
  spec.summary       = gem.description
  spec.homepage      = "https://github.com/fnichol/kb-ruby"
  gem.license        = 'Apache 2.0'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  gem.required_ruby_version = ">= 1.9.1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
