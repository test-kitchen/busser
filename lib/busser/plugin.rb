#
# Author:: Fletcher Nichol (<fnichol@nichol.ca>)
#
# Copyright (C) 2013, Fletcher Nichol
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

module Busser

  # Namespace that runner plugins define their classes inside.
  module RunnerPlugin
  end

  # Plugin loading logic.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  #
  module Plugin

    module_function

    # @param plugin_name [String] short plugin name, such as "bash"
    # @return [String] the path to require for that plugin
    def runner_plugin(plugin_name)
      "busser/runner_plugin/#{plugin_name}"
    end

    # Require paths for the named plugins, or for every installed plugin.
    #
    # @param plugin_names [Array<String>, String, nil] plugin names, or nil for
    #   everything installed
    # @return [Array<String>] require paths, without duplicates
    def runner_plugins(plugin_names = nil)
      if plugin_names
        Array(plugin_names).map { |plugin| runner_plugin(plugin) }.uniq
      else
        all_runner_plugins
      end
    end

    # Gem.find_files searches every installed gem version, not just the
    # newest, so a machine holding two versions of a plugin gem reports that
    # plugin twice. Callers treat each entry as one suite to run, so the
    # duplicates made `busser test` run a suite twice and `busser plugin list`
    # print it twice. The path is what gets required, and require resolves to
    # the active version, so collapsing the repeats is safe.
    # Require paths for every runner plugin installed on this machine.
    #
    # @return [Array<String>] require paths, without duplicates
    def all_runner_plugins
      Gem.find_files("busser/runner_plugin/*.rb").map do |file|
        "busser/runner_plugin/#{File.basename(file).sub(/\.rb$/, "")}"
      end.uniq
    end

    # Requires a plugin, exiting with a readable message rather than a
    # backtrace if it cannot be loaded.
    #
    # @param plugin_path [String] the path to require
    # @return [void]
    def require!(plugin_path)
      require plugin_path
    rescue LoadError => e
      Busser::UI.die "Could not load #{plugin_path} (#{e.class}: #{e.message})"
    end

    # @param klass [String, Symbol] a constant name inside
    #   {Busser::RunnerPlugin}
    # @return [Class] the runner plugin class
    def runner_class(klass)
      Busser::RunnerPlugin.const_get(klass)
    end

    # Finds the gemspec a plugin was loaded from.
    #
    # A plugin being developed locally is not an installed gem, so the local
    # gemspec is preferred when the plugin resolves inside the working tree.
    #
    # @param plugin_path [String] the plugin's require path
    # @return [Gem::Specification] the spec the plugin belongs to
    def gem_from_path(plugin_path)
      # Ask RubyGems first. Loading a gemspec *evaluates* it, and these
      # gemspecs shell out to `git ls-files` to build their file list -- so
      # asking the working tree first printed "fatal: not a git repository"
      # into the middle of `busser plugin list` for every installed plugin.
      # find_by_path answers from the installed specs without running anything.
      Gem::Specification.find_by_path(plugin_path) ||
        local_gemspec_for(plugin_path)
    end

    # Falls back to a gemspec in the working tree, which is how a plugin being
    # developed locally -- and so not installed as a gem -- is resolved.
    #
    # @param plugin_path [String] the plugin's require path
    # @return [Gem::Specification, nil] the spec, or nil if there is no local
    #   gemspec to read
    def local_gemspec_for(plugin_path)
      root = $LOAD_PATH.first
      return nil if root.nil?

      local_gem_path = File.expand_path(plugin_path, root)
      return nil if Dir.glob("#{local_gem_path}#{Gem.suffix_pattern}").empty?

      local_gemspec = File.join(File.dirname(root), "busser.gemspec")
      return nil unless File.exist?(local_gemspec)

      Gem::Specification.load(local_gemspec)
    end
  end
end
