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

require_relative "../spec_helper"

require "busser/plugin"
require "busser/ui"

describe Busser::Plugin do

  describe ".runner_plugin" do

    it "builds the require path for a plugin name" do
      _(Busser::Plugin.runner_plugin("bash"))
        .must_equal "busser/runner_plugin/bash"
    end
  end

  describe ".runner_plugins" do

    it "maps each given name to its require path" do
      _(Busser::Plugin.runner_plugins(%w{bash minitest})).must_equal [
        "busser/runner_plugin/bash",
        "busser/runner_plugin/minitest",
      ]
    end

    it "accepts a single name that is not in an array" do
      _(Busser::Plugin.runner_plugins("bash"))
        .must_equal ["busser/runner_plugin/bash"]
    end

    # Callers run one suite per entry, so a repeated name would run that
    # suite twice.
    it "returns a name given more than once only once" do
      _(Busser::Plugin.runner_plugins(%w{bash bash}))
        .must_equal ["busser/runner_plugin/bash"]
    end

    it "falls back to every installed plugin when given no names" do
      Busser::Plugin.expects(:all_runner_plugins).returns(["stubbed"])

      _(Busser::Plugin.runner_plugins).must_equal ["stubbed"]
    end
  end

  describe ".all_runner_plugins" do

    it "turns each found file into a require path" do
      stub_found_files %w{
        /gems/busser-bash-0.1.1/lib/busser/runner_plugin/bash.rb
        /gems/busser-serverspec-0.5.0/lib/busser/runner_plugin/serverspec.rb
      }

      _(Busser::Plugin.all_runner_plugins).must_equal [
        "busser/runner_plugin/bash",
        "busser/runner_plugin/serverspec",
      ]
    end

    # Gem.find_files searches every installed version of every gem. A machine
    # that has installed a plugin more than once therefore reports it once per
    # version, which made `busser test` run that suite repeatedly and
    # `busser plugin list` print it repeatedly.
    it "reports a plugin once when several versions of its gem are installed" do
      stub_found_files %w{
        /gems/busser-bash-0.1.1/lib/busser/runner_plugin/bash.rb
        /gems/busser-bash-0.1.0/lib/busser/runner_plugin/bash.rb
      }

      _(Busser::Plugin.all_runner_plugins)
        .must_equal ["busser/runner_plugin/bash"]
    end

    it "keeps the first occurrence, which is the newest version found" do
      stub_found_files %w{
        /gems/busser-bash-0.1.1/lib/busser/runner_plugin/bash.rb
        /gems/busser-bash-0.1.0/lib/busser/runner_plugin/bash.rb
        /gems/busser-serverspec-0.5.0/lib/busser/runner_plugin/serverspec.rb
      }

      _(Busser::Plugin.all_runner_plugins).must_equal [
        "busser/runner_plugin/bash",
        "busser/runner_plugin/serverspec",
      ]
    end

    it "returns nothing when no plugins are installed" do
      stub_found_files []

      _(Busser::Plugin.all_runner_plugins).must_equal []
    end

    def stub_found_files(files)
      Gem.expects(:find_files)
        .with("busser/runner_plugin/*.rb")
        .returns(files)
    end
  end

  describe ".require!" do

    it "requires the given path" do
      Busser::Plugin.expects(:require).with("busser/runner_plugin/bash")

      Busser::Plugin.require!("busser/runner_plugin/bash")
    end

    # A plugin gem that is listed but not loadable is a common failure on a
    # test instance, and the message is the only clue the user gets.
    it "dies with the offending path when the plugin cannot be loaded" do
      Busser::Plugin.stubs(:require).raises(LoadError, "no such file")
      Busser::UI.expects(:die).with do |message|
        message.include?("busser/runner_plugin/nope") &&
          message.include?("LoadError") &&
          message.include?("no such file")
      end

      Busser::Plugin.require!("busser/runner_plugin/nope")
    end
  end
end
