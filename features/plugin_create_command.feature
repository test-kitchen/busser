Feature: Plugin create command
  In order to make plugin development a snap
  As a user of Busser
  I want a command to run that will give me a plugin gem project scaffold

  Scenario: Running with default values
    When I run `busser plugin create junit`
    Then a directory named "busser-junit" should exist
    And the file "busser-junit/CHANGELOG.md" should contain:
    """
    ## 0.1.0 / Unreleased
    """
    And the file "busser-junit/Gemfile" should contain "gemspec"
    And the file "busser-junit/Rakefile" should contain "task :stats"
    And the file "busser-junit/README.md" should contain:
    """
    Busser::RunnerPlugin::Junit
    """
    And the file "busser-junit/busser-junit.gemspec" should contain:
    """
    require 'busser/junit/version'
    """
    And the file "busser-junit/LICENSE" should contain:
    """
    Licensed under the Apache License, Version 2.0
    """
    And the file "busser-junit/.gitignore" should contain:
    """
    Gemfile.lock
    """
    And the file "busser-junit/.tailor" should contain:
    """
    config.file_set 'lib/**/*.rb'
    """
    And the file "busser-junit/.travis.yml" should contain:
    """
    language: ruby
    """
    And a file named "busser-junit/.cane" should exist
    And the file "busser-junit/lib/busser/junit/version.rb" should contain:
    """
    module Busser

      module Junit
    """
    And the file "busser-junit/lib/busser/runner_plugin/junit.rb" should contain:
    """
    class Busser::RunnerPlugin::Junit < Busser::RunnerPlugin::Base
    """
    And the file "busser-junit/features/support/env.rb" should contain:
    """
    require 'busser/cucumber'
    """
    And the file "busser-junit/features/plugin_install_command.feature" should contain:
    """
    When I run `busser plugin install busser-junit --force-postinstall`
    """
    And the file "busser-junit/features/plugin_list_command.feature" should contain:
    """
    When I successfully run `busser plugin list`
    """
    And the file "busser-junit/features/test_command.feature" should contain:
    """
    Given a suite directory named "junit"
    """

  Scenario: Running with an alternate license
    When I successfully run `busser plugin create foo --license=reserved`
    Then the file "busser-foo/LICENSE" should contain:
    """
    All rights reserved - Do Not Redistribute
    """
