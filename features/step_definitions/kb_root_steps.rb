require 'tmpdir'

Given(/^a KB_ROOT of "(.*?)"$/) do |kb_root|
  ENV['KB_ROOT'] = kb_root
end

Given(/^a test KB_ROOT directory named "(.*?)"$/) do |name|
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

Then(/^the suite directory named "(.*?)" should not exist$/) do |name|
  directory = File.join(ENV['KB_ROOT'], "suites", name)
  check_directory_presence([directory], false)
end
