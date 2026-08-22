begin
  require "aruba/cucumber"
rescue LoadError
  abort "The aruba gem must be in your development dependencies"
end

require "busser/cucumber/hooks"

require "fileutils" unless defined?(FileUtils)
require "tmpdir" unless defined?(Dir.mktmpdir)
require "pathname" unless defined?(Pathname)

Given(/^a BUSSER_ROOT of "(.*?)"$/) do |busser_root|
  backup_envvar("BUSSER_ROOT")

  ENV["BUSSER_ROOT"] = busser_root
end

Given(/^a test BUSSER_ROOT directory named "(.*?)"$/) do |name|
  backup_envvar("BUSSER_ROOT")

  busser_root = Pathname.new(Dir.mktmpdir(name))
  (busser_root + "suites").mkpath
  ENV["BUSSER_ROOT"] = busser_root.to_s
  # aruba 2.x runs commands with its own environment, so set it there too
  set_environment_variable("BUSSER_ROOT", busser_root.to_s)
  @busser_root_dirs << busser_root
end

Given(/^I delete the BUSSER_ROOT directory$/) do
  FileUtils.rm_rf(ENV["BUSSER_ROOT"])
end

Given(/^a suite directory named "(.*?)"$/) do |name|
  FileUtils.mkdir_p(File.join(ENV["BUSSER_ROOT"], "suites", name))
end

Given(/^a file in suite "(.*?)" named "(.*?)" with:$/) do |suite, file, content|
  # BUSSER_ROOT is outside aruba's working directory, and aruba 1.0+ refuses
  # absolute paths in its file helpers, so write it directly.
  file_name = File.join(ENV["BUSSER_ROOT"], "suites", suite, file)
  FileUtils.mkdir_p(File.dirname(file_name))
  File.write(file_name, content)
end

Given(/^a sandboxed GEM_HOME directory named "(.*?)"$/) do |name|
  backup_envvar("GEM_HOME")
  backup_envvar("GEM_PATH")

  gem_home = Pathname.new(Dir.mktmpdir(name))
  ENV["GEM_HOME"] = gem_home.to_s
  ENV["GEM_PATH"] = [gem_home.to_s, ENV["GEM_PATH"]].join(":")
  set_environment_variable("GEM_HOME", ENV["GEM_HOME"])
  set_environment_variable("GEM_PATH", ENV["GEM_PATH"])
  @busser_root_dirs << gem_home
end

Given(/^a non bundler environment$/) do
  %w{BUNDLER_EDITOR BUNDLE_BIN_PATH BUNDLE_GEMFILE RUBYOPT}.each do |key|
    backup_envvar(key)
    ENV.delete(key)
    delete_environment_variable(key)
  end

  # BUNDLE_PATH makes RubyGems install into the bundle rather than GEM_HOME,
  # so drop it -- but keep the bundle's gems reachable through GEM_PATH.
  if ENV["BUNDLE_PATH"]
    bundled = Dir.glob(File.join(ENV["BUNDLE_PATH"], "ruby", "*")).first
    backup_envvar("BUNDLE_PATH")
    ENV.delete("BUNDLE_PATH")
    delete_environment_variable("BUNDLE_PATH")
    if bundled
      ENV["GEM_PATH"] = [ENV["GEM_PATH"], bundled].compact.reject(&:empty?).join(":")
      set_environment_variable("GEM_PATH", ENV["GEM_PATH"])
    end
  end
end

Then(/^the suite directory named "(.*?)" should exist$/) do |name|
  directory = File.join(ENV["BUSSER_ROOT"], "suites", name)
  expect(Dir).to exist(directory)
end

Then(/^the suite directory named "(.*?)" should not exist$/) do |name|
  directory = File.join(ENV["BUSSER_ROOT"], "suites", name)
  expect(Dir).to_not exist(directory)
end

Then(/^the suite file "(.*?)" should contain exactly:$/) do |file, content|
  file_name = File.join(ENV["BUSSER_ROOT"], "suites", file)
  expect(File.read(file_name)).to eq(content)
end

Then(/^the vendor directory named "(.*?)" should exist$/) do |name|
  directory = File.join(ENV["BUSSER_ROOT"], "vendor", name)
  expect(Dir).to exist(directory)
end

Then(/^the vendor directory named "(.*?)" should not exist$/) do |name|
  directory = File.join(ENV["BUSSER_ROOT"], "vendor", name)
  expect(Dir).to_not exist(directory)
end

Then(/^the vendor file "(.*?)" should contain "(.*?)"$/) do |file, content|
  file_name = File.join(ENV["BUSSER_ROOT"], "vendor", file)
  expect(File.read(file_name)).to include(content)
end

# Check the sandboxed GEM_HOME directly. Shelling out to `gem list` depends on
# the child process inheriting the sandbox and a bundler-free environment,
# which aruba 2.x no longer arranges for us.
Then(/^a gem named "(.*?)" is installed with version "(.*?)"$/) do |name, ver|
  specs = Dir.glob(File.join(ENV["GEM_HOME"], "specifications", "#{name}-#{ver}.gemspec"))
  expect(specs).to_not be_empty
end

Then(/^a gem named "(.*?)" is installed$/) do |name|
  specs = Dir.glob(File.join(ENV["GEM_HOME"], "specifications", "#{name}-*.gemspec"))
  expect(specs).to_not(be_empty, -> { "GEM_HOME=#{ENV["GEM_HOME"]} cmd_output=#{last_command_started.output}" })
end

Then(/^the BUSSER_ROOT directory should exist$/) do
  expect(Dir).to exist(ENV["BUSSER_ROOT"])
end

Then(/^a busser binstub file should contain:$/) do |partial_content|
  file = File.join(ENV["BUSSER_ROOT"], %w{bin busser})
  expect(File.read(file)).to include(partial_content)
end

Then(/^a bat busser binstub file should contain:$/) do |partial_content|
  file = File.join(ENV["BUSSER_ROOT"], %w{bin busser.bat})
  expect(File.read(file)).to include(partial_content)
end

Then(/^pry me$/) do
  require "pry"; binding.pry # rubocop:disable Lint/Debugger
end
