# -*- encoding: utf-8 -*-
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

require 'rubygems/dependency_installer'

module Busser

  # RubyGems API abstraction logic, used to install and verify plugins.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  #
  module RubyGems

    module_function

    def gem_installed?(name, version)
      installed = Array(Gem::Specification.find_all_by_name(name, version))
      version = latest_gem_version(name) if version.nil?

      if version.nil?
        ! installed.empty?
      else
        installed.find { |spec| spec.version.to_s == version }
      end
    end

    def install_gem(gem, version)
      install_arg = gem =~ /\.gem$/ ? gem : new_dep(gem, version)
      spec = dep_installer.install(install_arg).find { |s| s.name == gem }
      Gem.clear_paths
      spec
    end

    def latest_gem_version(name)
      available_gems = dep_installer.find_gems_with_sources(new_dep(name))

      spec, source = if available_gems.respond_to?(:last)
        # DependencyInstaller sorts the results such that the last one is
        # always the one it considers best.
        spec_with_source = available_gems.last
        spec_with_source && spec_with_source
      else
        # Rubygems 2.0 returns a Gem::Available set, which is a
        # collection of AvailableSet::Tuple structs
        available_gems.pick_best!
        best_gem = available_gems.set.first
        best_gem && [best_gem.spec, best_gem.source]
      end

      spec && spec.version && spec.version.to_s
    end

    def silence_gem_ui
      interaction = Gem::DefaultUserInteraction.ui
      Gem::DefaultUserInteraction.ui = Gem::SilentUI.new
      yield
    ensure
      Gem::DefaultUserInteraction.ui = interaction
    end

    def dep_installer
      Gem::DependencyInstaller.new
    end

    def new_dep(name, version = nil)
      Gem::Dependency.new(name, version)
    end
  end
end
