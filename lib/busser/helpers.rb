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

require 'pathname' unless defined?(Pathname)

require 'busser/rubygems'

module Busser

  # Common methods used by subcommands.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  #
  module Helpers

    module_function

    def suite_path(name = nil)
      path = root_path + "suites"
      path += name if name
      path.expand_path
    end

    def vendor_path(product = nil)
      path = root_path + "vendor"
      path += product if product
      path.expand_path
    end

    def root_path
      Pathname.new(ENV['BUSSER_ROOT'] || "/opt/busser")
    end

    def chef_apply(config = {}, &block)
      warn "Apologies, but Busser no longer supports the chef_apply helper," +
        " so the contents of this block will not be exectued. Please refactor" +
        " your code to use Thor actions, shell out commands or another" +
        " strategy"
    end

    def install_gem(gem, version = nil)
      Busser::RubyGems.install_gem(gem, version)
    end
  end
end
