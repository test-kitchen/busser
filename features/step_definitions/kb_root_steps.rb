require 'tmpdir'
require 'pathname'

Given(/^a KB_ROOT of "(.*?)"$/) do |kb_root|
  backup_envvar('KB_ROOT')

  ENV['KB_ROOT'] = kb_root
end

Given(/^a test KB_ROOT directory named "(.*?)"$/) do |name|
  backup_envvar('KB_ROOT')

  kb_root = Pathname.new(Dir.mktmpdir(name))
  (kb_root + "suites").mkpath
  ENV['KB_ROOT'] = kb_root.to_s
  @kb_root_dirs << kb_root
end

Given(/^I delete the KB_ROOT directory$/) do
  FileUtils.rm_rf(ENV['KB_ROOT'])
end

Given(/^a suite directory named "(.*?)"$/) do |name|
  FileUtils.mkdir_p(File.join(ENV['KB_ROOT'], "suites", name))
end

Given(/^a sandboxed GEM_HOME directory named "(.*?)"$/) do |name|
  backup_envvar('GEM_HOME')
  backup_envvar('GEM_PATH')

  gem_home = Pathname.new(Dir.mktmpdir(name))
  ENV['GEM_HOME'] = gem_home.to_s
  ENV['GEM_PATH'] = [gem_home.to_s, ENV['GEM_PATH']].join(':')
  @kb_root_dirs << gem_home
end

Then(/^the suite directory named "(.*?)" should not exist$/) do |name|
  directory = File.join(ENV['KB_ROOT'], "suites", name)
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
