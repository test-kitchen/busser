require "aruba/cucumber"
require "busser/cucumber"

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.command_name "features"
end

Aruba.configure do |config|
  config.exit_timeout = 20
end
