require_relative "../../spec_helper"

require "busser/command/plugin_list"

describe Busser::Command::PluginList do
  let(:command) { Busser::Command::PluginList.new }

  describe "#plugin_data" do
    def stub_plugins(paths, specs = {})
      Busser::Plugin.stubs(:runner_plugins).returns(paths)
      paths.each do |path|
        Busser::Plugin.stubs(:gem_from_path).with(path).returns(specs[path])
      end
    end

    def spec_for(name, version)
      Gem::Specification.new { |s| s.name = name; s.version = version }
    end

    it "reports each plugin's short name and version" do
      stub_plugins(["busser/runner_plugin/bash"],
        "busser/runner_plugin/bash" => spec_for("busser-bash", "0.2.0"))

      _(command.send(:plugin_data)).must_equal [["bash", Gem::Version.new("0.2.0")]]
    end

    # dummy is a fixture shipped inside busser for its own tests, not something
    # anyone installed. `busser test` already passes over it, so listing it was
    # inconsistent as well as confusing.
    it "leaves out the internal dummy runner" do
      stub_plugins(["busser/runner_plugin/dummy", "busser/runner_plugin/bash"],
        "busser/runner_plugin/bash" => spec_for("busser-bash", "0.2.0"))

      _(command.send(:plugin_data).map(&:first)).must_equal %w{bash}
    end

    it "reports a nil version rather than raising when no spec is found" do
      stub_plugins(["busser/runner_plugin/bash"])

      _(command.send(:plugin_data)).must_equal [["bash", nil]]
    end

    it "returns an empty list when dummy is all there is" do
      stub_plugins(["busser/runner_plugin/dummy"])

      _(command.send(:plugin_data)).must_be_empty
    end
  end
end
