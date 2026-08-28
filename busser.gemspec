lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "busser/version"

Gem::Specification.new do |spec|
  spec.name          = "busser"
  spec.version       = Busser::VERSION
  spec.authors       = ["Fletcher Nichol"]
  spec.email         = ["fnichol@nichol.ca"]
  spec.description   = %q{Busser - Runs tests for projects in Test Kitchen}
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/test-kitchen/busser"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.1"

  # thor 1.1.0 references DidYouMean::SPELL_CHECKERS, removed in Ruby 3.1,
  # so the CLI crashed on startup on every supported Ruby
  spec.add_dependency "thor", ">= 1.1"
  # base64 is no longer a default gem; deserialize needs it at runtime
  spec.add_dependency "base64"

  spec.add_development_dependency "aruba", ">= 2.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "rake"
end
