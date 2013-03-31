Feature: Plugin install command
  In order to let user test they way they want to test
  As a user of Busser
  I want the ability to install test runner plugins

  Background:
    Given a sandboxed GEM_HOME directory named "busser-plugin"

  Scenario: Installing a missing plugin
    When I run `busser plugin install rack`
    Then the output should contain "Plugin rack installed"
    And the exit status should be 0
    And a gem named "rack" is installed

  Scenario: Installing a missing plugin with a version
    When I run `busser plugin install rack@1.2.8`
    Then the output should contain "Plugin rack@1.2.8 installed (version 1.2.8)"
    And the exit status should be 0
    And a gem named "rack" is installed with version "1.2.8"

  Scenario: Installing a specfic newer version of an existing plugin
    When I successfully run `busser plugin install rack@1.2.8`
    And I run `busser plugin install rack@1.3.10`
    Then the output should contain "Plugin rack@1.3.10 installed (version 1.3.10)"
    And the exit status should be 0
    And a gem named "rack" is installed with version "1.3.10"

  Scenario: Installing an internal plugin
    When I run `busser plugin install dummy`
    Then the output should contain "dummy plugin already installed"
    And the exit status should be 0
