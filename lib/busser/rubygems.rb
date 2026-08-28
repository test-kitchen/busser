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

require "rubygems/dependency_installer"

module Busser

  # RubyGems API abstraction logic, used to install and verify plugins.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  #
  module RubyGems

    module_function

    # @param name [String] the gem name
    # @param version [String, nil] a requirement string, or nil for any version
    # @return [Boolean] true if a matching gem is already available
    def gem_installed?(name, version)
      version = Gem::Requirement.default unless version
      ! Gem::Dependency.new(name, version).matching_specs.empty?
    end

    # Installs a gem into GEM_HOME.
    #
    # RubyGems under bundler points Gem.dir at the bundle, which is not where
    # Busser plugins belong, so GEM_HOME is applied explicitly before the
    # install and the freshly installed spec is put on the load path by hand.
    #
    # @param gem_name [String] the gem name
    # @param version [String, nil] a requirement string, or nil for any version
    # @return [Gem::Specification, nil] the installed spec, or nil if the gem
    #   was not among those installed
    def install_gem(gem_name, version)
      version = Gem::Requirement.default unless version

      # A bundler-managed environment can leave Gem.dir pointing at the bundle,
      # which is not where busser plugins belong. Point RubyGems at GEM_HOME.
      gem_home = ENV.fetch("GEM_HOME", nil)
      Gem.use_paths(gem_home, Gem.path) if gem_home && Gem.dir != gem_home

      inst = Gem::DependencyInstaller.new(rbg_options)
      specs = inst.install(gem_name, Gem::Requirement.create(version))

      Gem.clear_paths
      spec = specs.find { |s| s.name == gem_name }
      # Modern RubyGems does not put a freshly installed gem on the load path.
      # Add it directly rather than activating, so installing a second version
      # in the same process does not raise a Gem::LoadError conflict.
      spec&.full_require_paths&.each do |path|
        $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
      end
      spec
    end

    # @return [Hash] options handed to RubyGems' dependency installer, with
    #   the install directory pinned to GEM_HOME
    def rbg_options
      @rbg_options ||= Gem::DependencyInstaller::DEFAULT_OPTIONS.merge(
        suggest_alternate: false,
        version: Gem::Requirement.default,
        without_groups: [],
        minimal_deps: true,
        # Install into GEM_HOME explicitly. Under bundler Gem.dir points at the
        # bundle path, which is not where busser plugins belong.
        install_dir: ENV.fetch("GEM_HOME", nil),
        http_proxy: ENV.fetch("http_proxy", ENV.fetch("HTTP_PROXY", nil))
      )
    end

    # Runs a block with RubyGems' own progress output suppressed, unless the
    # user asked for verbose output.
    #
    # @yield the block to run quietly
    # @return [Object] whatever the block returned
    def silence_gem_ui
      interaction = Gem::DefaultUserInteraction.ui
      unless Gem.configuration.really_verbose
        Gem::DefaultUserInteraction.ui = Gem::SilentUI.new
      end
      yield
    ensure
      Gem::DefaultUserInteraction.ui = interaction
    end
  end
end
