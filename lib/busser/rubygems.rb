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
      version = Gem::Requirement.default unless version
      ! Gem::Dependency.new(name, version).matching_specs.empty?
    end

    def install_gem(gem, version)
      version = Gem::Requirement.default unless version

      inst = Gem::DependencyInstaller.new(rbg_options)
      specs = inst.install(gem, Gem::Requirement.create(version))

      Gem.clear_paths
      specs.find { |s| s.name == gem }
    end

    def rbg_options
      @rbg_options ||= Gem::DependencyInstaller::DEFAULT_OPTIONS.merge(
        :suggest_alternate => false,
        :version => Gem::Requirement.default,
        :without_groups => [],
        :minimal_deps => true,
        :http_proxy => ENV.fetch("http_proxy", ENV.fetch("HTTP_PROXY", nil))
      )
    end

    def silence_gem_ui
      interaction = Gem::DefaultUserInteraction.ui
      if !Gem.configuration.really_verbose
        Gem::DefaultUserInteraction.ui = Gem::SilentUI.new
      end
      yield
    ensure
      Gem::DefaultUserInteraction.ui = interaction
    end
  end
end
