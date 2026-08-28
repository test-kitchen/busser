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

require "busser/plugin"
require "busser/thor"

module Busser

  module Command

    # Plugin list command.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    #
    class PluginList < Busser::Thor::BaseGroup

      # Prints the installed plugins and their versions.
      #
      # @return [void]
      def list
        if plugin_data.empty?
          say "No plugins installed yet"
        else
          print_table([%w{Plugin Version}] + plugin_data)
        end
      end

      private

      # The dummy runner is a fixture shipped inside busser for its own tests,
      # not something anyone installed. `busser test` already passes over it,
      # so listing it as an installed plugin was inconsistent as well as
      # confusing.
      #
      # @return [Array<Array(String, String)>] each installed plugin's short
      #   name and version
      def plugin_data
        @plugin_data ||= Busser::Plugin.runner_plugins
          .reject { |path| File.basename(path) == "dummy" }
          .map do |path|
            spec = Busser::Plugin.gem_from_path(path)
            [File.basename(path), (spec && spec.version)]
          end
      end
    end
  end
end
