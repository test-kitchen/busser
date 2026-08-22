require "bundler/gem_tasks"
require 'rake/testtask'
require 'cucumber/rake/task'

Rake::TestTask.new(:unit) do |t|
  t.libs.push "lib"
  t.test_files = FileList['spec/**/*_spec.rb']
  t.verbose = true
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = ['features', '-x', '--format progress', '--no-color', '-b']
end

desc "Run all test suites"
task :test => [:unit, :features]


desc "Display LOC stats"
task :stats do
  puts "\n## Production Code Stats"
  sh "countloc -r lib"
  puts "\n## Test Code Stats"
  sh "countloc -r spec features"
end

desc "Run all quality tasks"
task :quality => [:stats]

task :default => [:test, :quality]
