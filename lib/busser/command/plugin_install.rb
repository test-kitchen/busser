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

require "openssl" unless defined?(OpenSSL)

require "busser/rubygems"
require "busser/thor"

module Busser

  module Command

    # Plugin install command.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    #
    class PluginInstall < Busser::Thor::BaseGroup

      include Busser::RubyGems

      argument :plugins, type: :array

      class_option :force_postinstall, type: :boolean, default: false,
        desc: "Run the plugin's postinstall if it is already installed"

      class_option :verbose, type: :boolean, default: false,
        desc: "Set a more verbose output"

      # Installs each requested plugin.
      #
      # @return [void]
      def install_all
        if options[:verbose]
          Gem.configuration.verbose = 2 if options[:verbose]
          info("Using http_proxy=#{rbg_options[:http_proxy].inspect}")
        end

        silence_gem_ui do
          plugins.each { |plugin| install(plugin) }
        end
      end

      private

      # Installs one plugin and runs its postinstall.
      #
      # @param plugin [String] gem name, optionally suffixed with @version
      # @return [void]
      def install(plugin)
        gem_name, version = plugin.split("@")
        name = gem_name.sub(/^busser-/, "")

        new_install = install_plugin_gem(gem_name, version, name)

        if options[:force_postinstall] || new_install
          load_plugin(name)
          run_postinstall(name)
        end
      end

      # Installs the plugin gem unless it is already available.
      #
      # @param gem [String] the gem name
      # @param version [String, nil] a version requirement, or nil for any
      # @param name [String] short plugin name, for the message
      # @return [Boolean] true if the gem was newly installed
      def install_plugin_gem(gem, version, name)
        if internal_plugin?(name) || gem_installed?(gem, version)
          info "Plugin #{name} already installed"
          false
        else
          spec = install_gem(gem, version)
          info "Plugin #{name} installed (version #{spec.version})"
          true
        end
      end

      # @param name [String] short plugin name
      # @return [void]
      def load_plugin(name)
        Busser::Plugin.require!(Busser::Plugin.runner_plugin(name))
      end

      # Runs the plugin's postinstall block, which is where a plugin installs
      # the test framework it drives.
      #
      # @param name [String] short plugin name
      # @return [void]
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
      # The restore is in an ensure block. Without one, a postinstall that
      # raised left VERIFY_PEER set to VERIFY_NONE for the rest of the
      # process -- and `busser plugin install` takes a list, so every gem
      # downloaded for every later plugin in that same run would have had its
      # certificate unchecked.
      #
      # @yield the block to run with peer verification dropped
      # @return [void]
      def drop_ssl_verify_peer
        before = OpenSSL::SSL::VERIFY_PEER
        set_ssl_verify_peer(OpenSSL::SSL::VERIFY_NONE)
        begin
          yield
        ensure
          set_ssl_verify_peer(before)
        end
      end

      # @param value [Integer] the OpenSSL verify mode to install
      # @return [void]
      def set_ssl_verify_peer(value)
        OpenSSL::SSL.send(:remove_const, "VERIFY_PEER")
        OpenSSL::SSL.const_set("VERIFY_PEER", value)
      end
    end
  end
end
