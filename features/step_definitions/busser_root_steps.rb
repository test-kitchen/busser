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

Given(/^a sandboxed GEM_HOME directory named "(.*?)"$/) do |name|
  backup_envvar('GEM_HOME')
  backup_envvar('GEM_PATH')

  gem_home = Pathname.new(Dir.mktmpdir(name))
  ENV['GEM_HOME'] = gem_home.to_s
  ENV['GEM_PATH'] = [gem_home.to_s, ENV['GEM_PATH']].join(':')
  @busser_root_dirs << gem_home
end

Then(/^the suite directory named "(.*?)" should not exist$/) do |name|
  directory = File.join(ENV['BUSSER_ROOT'], "suites", name)
  check_directory_presence([directory], false)
end

Then(/^a gem named "(.*?)" is installed with version "(.*?)"$/) do |name, version|
  unbundlerize do
    run_simple(unescape("gem list #{name} --version #{version} -i"), true, nil)
  end
end

Then(/^a gem named "(.*?)" is installed$/) do |name|
  unbundlerize do
    run_simple(unescape("gem list #{name} -i"), true, nil)
  end
end

Then(/^pry me$/) do
  require 'pry' ; binding.pry
end
