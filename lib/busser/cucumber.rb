begin
  require 'aruba/cucumber'
rescue LoadError
  abort "The aruba gem must be in your development dependencies"
end

require 'busser/cucumber/hooks'

require 'tmpdir'
require 'pathname'

Given(/^a BUSSER_ROOT of "(.*?)"$/) do |busser_root|
  backup_envvar('BUSSER_ROOT')

  ENV['BUSSER_ROOT'] = busser_root
end

Given(/^a test BUSSER_ROOT directory named "(.*?)"$/) do |name|
  backup_envvar('BUSSER_ROOT')

  busser_root = Pathname.new(Dir.mktmpdir(name))
  (busser_root + "suites").mkpath
  ENV['BUSSER_ROOT'] = busser_root.to_s
  @busser_root_dirs << busser_root
end

Given(/^I delete the BUSSER_ROOT directory$/) do
  FileUtils.rm_rf(ENV['BUSSER_ROOT'])
end

Given(/^a suite directory named "(.*?)"$/) do |name|
  FileUtils.mkdir_p(File.join(ENV['BUSSER_ROOT'], "suites", name))
end

Given(/^a file in suite "(.*?)" named "(.*?)" with:$/) do |suite, file, content|
  file_name = File.join(ENV['BUSSER_ROOT'], "suites", suite, file)
  write_file(file_name, content)
end

Given(/^a sandboxed GEM_HOME directory named "(.*?)"$/) do |name|
  backup_envvar('GEM_HOME')
  backup_envvar('GEM_PATH')

  gem_home = Pathname.new(Dir.mktmpdir(name))
  ENV['GEM_HOME'] = gem_home.to_s
  ENV['GEM_PATH'] = [gem_home.to_s, ENV['GEM_PATH']].join(':')
  @busser_root_dirs << gem_home
end

Given(/^a non bundler environment$/) do
  %w[BUNDLER_EDITOR BUNDLE_BIN_PATH BUNDLE_GEMFILE RUBYOPT].each do |key|
    backup_envvar(key)
    ENV.delete(key)
  end
end

Then(/^the suite directory named "(.*?)" should not exist$/) do |name|
  directory = File.join(ENV['BUSSER_ROOT'], "suites", name)
  check_directory_presence([directory], false)
end

Then(/^a gem named "(.*?)" is installed with version "(.*?)"$/) do |name, ver|
  unbundlerize do
    run_simple(unescape("gem list #{name} --version #{ver} -i"), true, nil)
  end
end

Then(/^a gem named "(.*?)" is installed$/) do |name|
  unbundlerize do
    run_simple(unescape("gem list #{name} -i"), true, nil)
  end
end

Then(/^the BUSSER_ROOT directory should exist$/) do
  check_directory_presence([ENV['BUSSER_ROOT']], true)
end

Then(/^a busser binstub file should contain:$/) do |partial_content|
  file = File.join(ENV['BUSSER_ROOT'], %w{bin busser})
  check_file_content(file, partial_content, true)
end

Then(/^the file "(.*?)" should have permissions "(.*?)"$/) do |file, perms|
  in_current_dir do
    file_perms = sprintf("%o", File.stat(file).mode)
    file_perms = file_perms[2, 4]
    file_perms.should eq(perms)
  end
end

Then(/^pry me$/) do
  require 'pry' ; binding.pry
end
