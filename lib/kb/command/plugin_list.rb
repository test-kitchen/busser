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

require 'kb/plugin'
require 'kb/thor'

module KB

  module Command

    # Plugin list command.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    #
    class PluginList < KB::Thor::BaseGroup

      def list
        if plugin_data.empty?
          say "No plugins installed yet"
        else
          print_table([["Plugin", "Version"]] + plugin_data)
        end
      end

      private

      def plugin_data
        @plugin_data ||= KB::Plugin.runner_plugins.map do |path|
          spec = KB::Plugin.gem_from_path(path)
          [File.basename(path), (spec && spec.version)]
        end
      end
    end
  end
end
