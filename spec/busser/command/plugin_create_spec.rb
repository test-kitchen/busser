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

require "busser/command/plugin_create"

# The generated project is what a plugin author starts from, so the checks
# worth having are the ones a new project would trip over on day one.
describe Busser::Command::PluginCreate do

  before do
    @tmpdir = Dir.mktmpdir("busser-plugin-create")
    @pwd = Dir.pwd
    Dir.chdir(@tmpdir)
  end

  after do
    Dir.chdir(@pwd)
    FileUtils.rm_rf(@tmpdir)
  end

  describe "the generated gemspec" do

    it "loads" do
      generate

      _(gemspec.name).must_equal "busser-demo"
    end

    # RubyGems validates spec.license against the SPDX list and warns on
    # anything else. The generator used to emit "Apache 2.0", the human
    # readable name rather than the identifier.
    it "declares a license RubyGems recognises" do
      generate

      _(Gem::Licenses.match?(gemspec.license)).must_equal true
    end

    {
      "apachev2" => "Apache-2.0",
      "mit" => "MIT",
      "lgplv3" => "LGPL-3.0-only",
    }.each do |option, identifier|
      it "maps --license #{option} to #{identifier}" do
        generate(license: option)

        _(gemspec.license).must_equal identifier
      end
    end

    # "All rights reserved" has no SPDX identifier, so declaring nothing is
    # the only correct option.
    it "declares no license for an all rights reserved plugin" do
      generate(license: "reserved")

      _(gemspec.license).must_be_nil
    end

    # bundler ~> 1.3 cannot be satisfied by any bundler in use today, so a
    # freshly generated plugin failed to resolve before running anything.
    it "does not constrain bundler" do
      generate

      _(dev_dependencies).wont_include "bundler"
    end

    # cane, tailor and countloc have been unmaintained for about a decade.
    %w{cane tailor countloc}.each do |gem_name|
      it "does not depend on #{gem_name}" do
        generate

        _(dev_dependencies).wont_include gem_name
      end
    end

    it "depends on what the generated Rakefile needs" do
      generate

      _(dev_dependencies).must_include "rake"
      _(dev_dependencies).must_include "cucumber"
      _(dev_dependencies).must_include "aruba"
    end

    it "states a supported Ruby version" do
      generate

      requirement = gemspec.required_ruby_version

      _(requirement.satisfied_by?(Gem::Version.new("3.2.0"))).must_equal true
      _(requirement.satisfied_by?(Gem::Version.new("2.7.0"))).must_equal false
    end

    def gemspec
      Gem::Specification.load(File.join(plugin_dir, "busser-demo.gemspec"))
    end

    def dev_dependencies
      gemspec.development_dependencies.map(&:name)
    end
  end

  describe "the generated project" do

    it "ships a CI workflow rather than a Travis config" do
      generate

      _(File.exist?(File.join(plugin_dir, ".github/workflows/test.yml")))
        .must_equal true
      _(File.exist?(File.join(plugin_dir, ".travis.yml"))).must_equal false
    end

    # Both linters are long dead, and the Rakefile's default task depended on
    # them, so `rake` failed on a freshly generated plugin.
    it "ships no dead linter configuration" do
      generate

      _(File.exist?(File.join(plugin_dir, ".tailor"))).must_equal false
      _(File.exist?(File.join(plugin_dir, ".cane"))).must_equal false
    end

    it "has a Rakefile that only references tasks it defines" do
      generate

      rakefile = File.read(File.join(plugin_dir, "Rakefile"))

      _(rakefile).wont_match(/cane|tailor|countloc/)
      _(rakefile).must_match(/Cucumber::Rake::Task/)
    end

    # aruba 1.0 dropped @aruba_timeout_seconds, and setting it on aruba 2 is
    # silently ignored, so the generated timeout did nothing at all.
    it "configures aruba through the supported API" do
      generate

      env = File.read(File.join(plugin_dir, "features/support/env.rb"))

      _(env).wont_match(/@aruba_timeout_seconds/)
      _(env).must_match(/Aruba\.configure/)
    end
  end

  def generate(license: "apachev2")
    command = Busser::Command::PluginCreate.new(
      ["demo"], { "type" => "runner", "license" => license }
    )
    command.stubs(:initialize_git)
    capture_stdout { command.create }
  end

  def plugin_dir
    File.join(@tmpdir, "busser-demo")
  end

  def capture_stdout
    original = $stdout
    $stdout = StringIO.new
    yield
  ensure
    $stdout = original
  end
end
