Feature: Suite path command
  In order to determine the directory containing suite tests
  As a user of kb
  I want a command to echo this directory on standard output

  Background:
    Given a KB_ROOT of "/path/to/kb"

  Scenario: Get base suite path
    When I successfully run `kb suite path`
    Then the output should contain exactly "/path/to/kb/suites\n"

  Scenario: Get suite path for a plugin
    When I successfully run `kb suite path footester`
    Then the output should contain exactly "/path/to/kb/suites/footester\n"
