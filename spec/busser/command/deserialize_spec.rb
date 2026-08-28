# -*- encoding: utf-8 -*-
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "../../spec_helper"

require "base64"
require "digest/md5"
require "tmpdir"

require "busser/command/deserialize"

# Deserialize is how Test Kitchen streams a file onto the instance under test,
# so the thing worth pinning down is what ends up on disk.
describe Busser::Command::Deserialize do

  CONTENTS = "Hello there.\n".freeze

  before do
    @tmpdir = Dir.mktmpdir("busser-deserialize")
    @file = File.join(@tmpdir, "nested", "decoded.txt")
  end

  after do
    FileUtils.rm_rf(@tmpdir)
  end

  describe "with a matching digest" do

    it "writes the decoded contents" do
      deserialize(md5sum: Digest::MD5.hexdigest(CONTENTS))

      _(File.read(@file)).must_equal CONTENTS
    end

    it "creates any missing parent directories" do
      deserialize(md5sum: Digest::MD5.hexdigest(CONTENTS))

      _(File.directory?(File.dirname(@file))).must_equal true
    end

    it "applies the requested permissions" do
      deserialize(md5sum: Digest::MD5.hexdigest(CONTENTS), perms: "0755")

      _(format("%o", File.stat(@file).mode & 0o777)).must_equal "755"
    end

    it "writes binary content unchanged" do
      binary = "\x00\x01\x02\xFF".dup.force_encoding("ASCII-8BIT")

      deserialize(contents: binary, md5sum: Digest::MD5.hexdigest(binary))

      _(File.binread(@file)).must_equal binary
    end
  end

  describe "with a mismatching digest" do

    it "fails the command" do
      _ { deserialize(md5sum: "not-the-right-digest") }.must_raise SystemExit
    end

    # The digest used to be checked only after the write, so a corrupted or
    # truncated stream still landed on disk, with its requested permissions,
    # for a later command to pick up and run.
    it "leaves no file behind" do
      _ { deserialize(md5sum: "not-the-right-digest") }.must_raise SystemExit

      _(File.exist?(@file)).must_equal false
    end

    it "does not overwrite a file that is already there" do
      FileUtils.mkdir_p(File.dirname(@file))
      File.write(@file, "original contents")

      _ { deserialize(md5sum: "not-the-right-digest") }.must_raise SystemExit

      _(File.read(@file)).must_equal "original contents"
    end
  end

  def deserialize(md5sum:, contents: CONTENTS, perms: "0644")
    STDIN.stubs(:read).returns(Base64.encode64(contents))

    command = Busser::Command::Deserialize.new([], {
      "destination" => @file,
      "md5sum" => md5sum,
      "perms" => perms,
    })
    capture_stderr { command.perform }
  end

  def capture_stderr
    original = $stderr
    $stderr = StringIO.new
    yield
  ensure
    $stderr = original
  end
end
