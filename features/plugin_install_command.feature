Feature: Plugin install command
  In order to let user test they way they want to test
  As a user of Busser
  I want the ability to install test runner plugins

  Background:
    Given a non bundler environment
    And a sandboxed GEM_HOME directory named "busser-plugin-gem-home"

  Scenario: Installing a missing plugin
    When I run `busser plugin install busser-bash`
    Then the output should contain "Plugin bash installed"
    And the exit status should be 0
    And a gem named "busser-bash" is installed

  Scenario: Installing a missing plugin with a version
    When I run `busser plugin install busser-bash@0.1.0`
    Then the output should contain "Plugin bash installed (version 0.1.0)"
    And the exit status should be 0
    And a gem named "busser-bash" is installed with version "0.1.0"

  Scenario: Installing a specfic newer version of an existing plugin
    When I successfully run `busser plugin install busser-bash@0.1.0`
    And I run `busser plugin install busser-bash@0.1.1`
    Then the output should contain "Plugin bash installed (version 0.1.1)"
    And the exit status should be 0
    And a gem named "busser-bash" is installed with version "0.1.1"

  Scenario: Installing an internal plugin
    When I run `busser plugin install dummy`
    Then the output should contain "Plugin dummy already installed"
    And the exit status should be 0

  Scenario: Forcing postinstall script for an internal plugin
    When I successfully run `busser plugin install dummy --force-postinstall`
    Then a directory named "dummy" should exist
    And the file "dummy/foobar.txt" should contain exactly:
    """
    The Dummy Driver.
    """
