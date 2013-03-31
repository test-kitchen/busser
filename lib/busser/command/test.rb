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

require 'busser/thor'
require 'busser/plugin'

module Busser

  module Command

    # Test command.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    #
    class Test < Busser::Thor::BaseGroup

      argument :plugins, :type => :array, :required => false

      def perform
        Busser::Plugin.runner_plugins(plugins).each do |runner_path|
          runner = File.basename(runner_path)
          next if skip_runner?(runner)
          klass = ::Thor::Util.camel_case(runner)

          banner "Running #{runner} test suite"
          Busser::Plugin.require!(runner_path)
          invoke Busser::Plugin.runner_class(klass)
        end
      end

      private

      def skip_runner?(runner)
        runner == "dummy" && ! Array(plugins).include?("dummy")
      end
    end
  end
end
