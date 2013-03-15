require 'simplecov'
require 'aruba/cucumber'

SimpleCov.command_name "features"

Before do
  @aruba_timeout_seconds = 5
  @kb_root_dirs = []
end

After do |s|
  # Tell Cucumber to quit after this scenario is done - if it failed.
  # This is useful to inspect the 'tmp/aruba' directory before any other
  # steps are executed and clear it out.
  Cucumber.wants_to_quit = true if s.failed?

  ENV['KB_ROOT'] = ENV.delete('_CUKE_KB_ROOT') if ENV['_CUKE_KB_ROOT']
  @kb_root_dirs.each { |dir| FileUtils.rm_rf(dir) }
end
