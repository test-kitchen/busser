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

require "tmpdir"

require "busser/command/setup"

# The binstub exists to give Busser an isolated gem environment on the machine
# under test, so what it does to the environment before exec is the contract
# worth pinning down.
describe Busser::Command::Setup do

  # Anything left set here lets the calling Ruby environment reach into
  # Busser's. RUBYOPT was once the only way in; RubyGems now requires
  # bundler/setup whenever BUNDLER_SETUP is present, and bundler then resets
  # GEM_HOME to the calling project's bundle.
  LEAKY_VARIABLES = %w{
    RUBYOPT GEMRC RUBYLIB
    BUNDLER_SETUP BUNDLER_VERSION
    BUNDLE_BIN_PATH BUNDLE_GEMFILE BUNDLE_LOCKFILE BUNDLE_PATH
  }.freeze

  before do
    @tmpdir = Dir.mktmpdir("busser-setup")
    @original_root = ENV["BUSSER_ROOT"]
    ENV["BUSSER_ROOT"] = @tmpdir
  end

  after do
    ENV["BUSSER_ROOT"] = @original_root
    FileUtils.rm_rf(@tmpdir)
  end

  describe "the bourne binstub" do

    it "is created and executable" do
      run_setup

      _(File.exist?(binstub)).must_equal true
      _(File.stat(binstub).mode & 0o111).wont_equal 0
    end

    it "pins BUSSER_ROOT and the gem paths" do
      run_setup

      _(binstub_body).must_match(/BUSSER_ROOT="#{Regexp.escape(@tmpdir)}"/)
      _(binstub_body).must_match(/^GEM_HOME=/)
      _(binstub_body).must_match(/^GEM_PATH=/)
    end

    LEAKY_VARIABLES.each do |name|
      it "unsets #{name} before exec" do
        run_setup

        _(unset_variables).must_include name
      end
    end

    it "unsets everything before handing off to ruby" do
      run_setup

      unset_line = binstub_body.index("unset ")
      exec_line = binstub_body.index("exec ")

      _(unset_line).must_be :<, exec_line
    end

    def binstub
      File.join(@tmpdir, "bin", "busser")
    end

    def unset_variables
      binstub_body.scan(/^unset (.+)$/).flatten.join(" ").split(/\s+/)
    end
  end

  describe "the bat binstub" do

    LEAKY_VARIABLES.each do |name|
      it "clears #{name} before exec" do
        run_setup(type: "bat")

        _(binstub_body).must_match(/^SET #{name}=\s*$/)
      end
    end

    def binstub
      File.join(@tmpdir, "bin", "busser.bat")
    end
  end

  def run_setup(type: "bourne")
    command = Busser::Command::Setup.new([], { "type" => type })
    capture_stdout { command.perform }
  end

  def binstub_body
    File.read(binstub)
  end

  def capture_stdout
    original = $stdout
    $stdout = StringIO.new
    yield
  ensure
    $stdout = original
  end
end
