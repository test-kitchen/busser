Feature: Suite cleanup command
  In order to have a fresh suite directory base for each test run
  As a user of Busser
  I want a command to clean any suite subdirectories

  Background:
    Given a test BUSSER_ROOT directory named "busser-suite"

  Scenario: A nonexistent base suite path
    Given I delete the BUSSER_ROOT directory
    When I run `busser suite cleanup`
    Then the output should contain "does not exist"
    And the exit status should be 0

  Scenario: An empty base suite path
    When I run `busser suite cleanup`
    Then the stdout should not contain anything
    And the exit status should be 0

  Scenario: A base suite path containing suite directories
    Given a suite directory named "bats"
    And a suite directory named "minitest"
    When I run `busser suite cleanup`
    Then the output should contain "bats"
    And the output should contain "minitest"
    And the suite directory named "bats" should not exist
    And the suite directory named "minitest" should not exist
    And the exit status should be 0
