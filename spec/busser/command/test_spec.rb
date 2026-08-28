require_relative "../../spec_helper"

require "shellwords"
require "busser/command/test"

describe Busser::Command::Test do
  describe ".prepare_sh_command" do
    it "runs the script with sh" do
      cmd = Busser::Command::Test.prepare_sh_command("/opt/busser/suites/bats/prepare.sh")

      _(Shellwords.split(cmd)).must_equal ["/bin/sh", "/opt/busser/suites/bats/prepare.sh"]
    end

    # BUSSER_ROOT is chosen by whoever runs Busser, and Test Kitchen puts it
    # under a path the user controls. Unquoted, a space split the path and sh
    # was handed a fragment.
    it "quotes a path containing spaces" do
      cmd = Busser::Command::Test.prepare_sh_command("/tmp/my tests/suites/bats/prepare.sh")

      _(Shellwords.split(cmd))
        .must_equal ["/bin/sh", "/tmp/my tests/suites/bats/prepare.sh"]
    end

    it "neutralises shell metacharacters in the path" do
      cmd = Busser::Command::Test.prepare_sh_command("/tmp/a;touch pwned/prepare.sh")

      _(Shellwords.split(cmd)).must_equal ["/bin/sh", "/tmp/a;touch pwned/prepare.sh"]
    end

    it "accepts a Pathname" do
      cmd = Busser::Command::Test.prepare_sh_command(Pathname.new("/a/prepare.sh"))

      _(Shellwords.split(cmd).last).must_equal "/a/prepare.sh"
    end
  end
end
