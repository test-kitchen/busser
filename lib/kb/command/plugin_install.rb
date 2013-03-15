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
require 'kb/thor'

module KB

  module Command

    # Plugin install command.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    #
    class PluginInstall < KB::Thor::BaseGroup

      argument :plugins, :type => :array

      def install_all
        silence_gem_ui!
        plugins.each { |plugin| install(plugin) }
      end

      private

      def install(plugin)
        install_gem(plugin)
      end

      def install_gem(plugin)
        name, version = plugin.split("@")

        if gem_installed?(name, version)
          info "#{plugin} plugin already installed"
        else
          spec = dep_installer.install(new_dep(name, version)).first
          info "Plugin #{plugin} installed (version #{spec.version})"
        end
      end

      def gem_installed?(name, version)
        installed = Array(Gem::Specification.find_all_by_name(name, version))
        version = latest_version(name) if version.nil?

        installed.find { |spec| spec.version.to_s == version }
      end

      def latest_version(name)
        spec = dep_installer.find_gems_with_sources(new_dep(name)).last.first
        spec && spec.version && spec.version.to_s
      end

      def silence_gem_ui!
        Gem::DefaultUserInteraction.ui = Gem::SilentUI.new
      end

      def dep_installer
        Gem::DependencyInstaller.new
      end

      def new_dep(name, version = nil)
        Gem::Dependency.new(name, version)
      end
    end
  end
end
