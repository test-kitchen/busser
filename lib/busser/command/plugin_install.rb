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

require 'openssl'

require 'busser/rubygems'
require 'busser/thor'

module Busser

  module Command

    # Plugin install command.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    #
    class PluginInstall < Busser::Thor::BaseGroup

      include Busser::RubyGems

      argument :plugins, :type => :array

      class_option :force_postinstall, :type => :boolean, :default => false,
        :desc => "Run the plugin's postinstall if it is already installed"

      def install_all
        silence_gem_ui do
          plugins.each { |plugin| install(plugin) }
        end
      end

      private

      def install(plugin)
        gem_name, version = plugin.split("@")
        name = gem_name.sub(/^busser-/, '')

        new_install = install_plugin_gem(gem_name, version, name)

        if options[:force_postinstall] || new_install
          load_plugin(name)
          run_postinstall(name)
        end
      end

      def install_plugin_gem(gem, version, name)
        if internal_plugin?(name) || gem_installed?(gem, version)
          info "Plugin #{name} already installed"
          return false
        else
          spec = install_gem(gem, version)
          info "Plugin #{name} installed (version #{spec.version})"
          return true
        end
      end

      def load_plugin(name)
        Busser::Plugin.require!(Busser::Plugin.runner_plugin(name))
      end

      def run_postinstall(name)
        klass = Busser::Plugin.runner_class(::Thor::Util.camel_case(name))
        if klass.respond_to?(:run_postinstall)
          banner "Running postinstall for #{name} plugin"
          drop_ssl_verify_peer { klass.run_postinstall }
        end
      end

      def internal_plugin?(name)
        spec = Busser::Plugin.gem_from_path(Busser::Plugin.runner_plugin(name))
        spec && spec.name == "busser"
      end

      # Drops SSL verify peer to VERIFY_NONE within a given block. While this
      # is normally a massive anti-pattern and should be discouraged, there
      # may be some Busser code that needs to be executed in an environment
      # that lacks a proper SSL certificate store.
      #
      # Please use with extreme caution.
      #
      def drop_ssl_verify_peer
        before = OpenSSL::SSL::VERIFY_PEER
        OpenSSL::SSL.send(:remove_const, 'VERIFY_PEER')
        OpenSSL::SSL.const_set('VERIFY_PEER', OpenSSL::SSL::VERIFY_NONE)
        yield
        OpenSSL::SSL.send(:remove_const, 'VERIFY_PEER')
        OpenSSL::SSL.const_set('VERIFY_PEER', before)
      end
    end
  end
end
