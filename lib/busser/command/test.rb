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

require "busser/thor"
require "busser/plugin"

module Busser

  # Namespace for Busser's subcommands.
  module Command

    # Test command.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    #
    class Test < Busser::Thor::BaseGroup

      argument :plugins, type: :array, required: false

      # Runs each requested plugin's suite, or every installed plugin's suite
      # when none were named.
      #
      # @return [void]
      def perform
        Busser::Plugin.runner_plugins(plugins).each do |runner_path|
          runner = File.basename(runner_path)
          next if skip_runner?(runner)

          klass = ::Thor::Util.camel_case(runner)

          banner "Running #{runner} test suite"
          Busser::Plugin.require!(runner_path)
          prepare_suite(runner)
          invoke Busser::Plugin.runner_class(klass)
        end
      end

      private

      # The dummy runner exists for Busser's own tests, so it only runs when
      # asked for by name.
      #
      # @param runner [String] short plugin name
      # @return [Boolean] true if this runner should be passed over
      def skip_runner?(runner)
        runner == "dummy" && ! Array(plugins).include?("dummy")
      end

      # Runs whatever preparation the suite ships before its tests.
      #
      # @param runner [String] short plugin name
      # @return [void]
      def prepare_suite(runner)
        run_prepare_sh(runner)
        run_prepare_recipe(runner)
      end

      # Runs the suite's prepare.sh, if it has one.
      #
      # @param runner [String] short plugin name
      # @return [void]
      def run_prepare_sh(runner)
        prepare_sh_script = suite_path(runner).join("prepare.sh")

        if prepare_sh_script.exist?
          banner "Preparing #{runner} suite with #{prepare_sh_script}"
          run!("/bin/sh #{prepare_sh_script}")
        end
      end

      # Warns if the suite still ships the prepare_recipe.rb that Busser
      # dropped support for, rather than ignoring it silently.
      #
      # @param runner [String] short plugin name
      # @return [void]
      def run_prepare_recipe(runner)
        prepare_recipe = suite_path(runner).join("prepare_recipe.rb")

        if prepare_recipe.exist?
          warn "Apologies, but Busser no longer supports the" +
            " prepare_recipe.rb file. Please use prepare.sh and optionally" +
            " shell out to chef-apply in an Omnibus installation."
        end
      end
    end
  end
end
