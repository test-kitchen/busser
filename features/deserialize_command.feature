Feature: Deserialize command
  In order to stream individual files over a text-based SSH session
  As a user of Busser
  I want a command that can accept a stream, decode, and install the file

  Scenario: Streaming a file
    When I run `bash -c "cat ../../features/files/base64.txt | busser deserialize --destination=decoded.txt --md5sum=c9f888ea2bf1c7409ece4ffe81111e4e --perms=0755"`
    Then the file "decoded.txt" should contain exactly:
    """
    Hello there.

    """
    And the file "decoded.txt" should have permissions "0755"
    And the exit status should be 0

  Scenario: Mismatching MD5 sum fails command
    When I run `bash -c "cat ../../features/files/base64.txt | busser deserialize --destination=decoded.txt --md5sum=nope --perms=0755"`
    Then the output should contain "does not match source file"
    Then the exit status should not be 0
