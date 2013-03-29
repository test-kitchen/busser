Feature: Suite path command
  In order to determine the directory containing suite tests
  As a user of Busser
  I want a command to echo this directory on standard output

  Background:
    Given a BUSSER_ROOT of "/path/to/busser"

  Scenario: Get base suite path
    When I successfully run `busser suite path`
    Then the output should contain exactly "/path/to/busser/suites\n"

  Scenario: Get suite path for a plugin
    When I successfully run `busser suite path footester`
    Then the output should contain exactly "/path/to/busser/suites/footester\n"
