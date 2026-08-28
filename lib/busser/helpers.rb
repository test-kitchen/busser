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

require "pathname" unless defined?(Pathname)

require "busser/rubygems"

module Busser

  # Common methods used by subcommands.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  #
  module Helpers

    module_function

    # Path to the suites directory, or to one suite inside it.
    #
    # @param name [String, nil] a suite name, or nil for the containing
    #   directory
    # @return [Pathname] absolute path beneath the Busser root
    def suite_path(name = nil)
      path = root_path + "suites"
      path += name if name
      path.expand_path
    end

    # Path to the vendor directory, or to one vendored product inside it.
    #
    # @param product [String, nil] a product name, or nil for the containing
    #   directory
    # @return [Pathname] absolute path beneath the Busser root
    def vendor_path(product = nil)
      path = root_path + "vendor"
      path += product if product
      path.expand_path
    end

    # The Busser root, where plugins, suites and vendored products live.
    #
    # @return [Pathname] BUSSER_ROOT if set, otherwise /opt/busser
    def root_path
      Pathname.new(ENV["BUSSER_ROOT"] || "/opt/busser")
    end

    # No longer supported. Kept so a plugin still calling it warns rather
    # than dying with a NoMethodError halfway through a test run.
    #
    # @param config [Hash] ignored
    # @return [void]
    # @deprecated Shell out or use a Thor action instead.
    def chef_apply(config = {}, &block)
      warn "Apologies, but Busser no longer supports the chef_apply helper," +
        " so the contents of this block will not be executed. Please refactor" +
        " your code to use Thor actions, shell out commands or another" +
        " strategy"
    end

    # Installs a gem into the Busser root's gem home.
    #
    # @param gem [String] the gem name
    # @param version [String, nil] a requirement string, or nil for any version
    # @return [Gem::Specification, nil] the spec that was installed
    def install_gem(gem, version = nil)
      Busser::RubyGems.install_gem(gem, version)
    end
  end
end
