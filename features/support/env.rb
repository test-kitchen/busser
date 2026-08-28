require "aruba/cucumber"
require "busser/cucumber"

Aruba.configure do |config|
  config.exit_timeout = 20
end
