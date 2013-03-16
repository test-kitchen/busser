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

module KB

  module RunnerPlugin
  end

  module Plugin

    module_function

    def runner_plugins(plugin_names = nil)
      if plugin_names
        Array(plugin_names).map { |plugin| "kb/runner_plugin/#{plugin}" }
      else
        all_runner_plugins
      end
    end

    def all_runner_plugins
      Gem.find_files('kb/runner_plugin/*.rb').map do |file|
        "kb/runner_plugin/#{File.basename(file).sub(/\.rb$/, '')}"
      end
    end

    def require!(plugin_path)
      require plugin_path
    rescue LoadError => e
      die "Could not load #{plugin_path} (#{e.class}: #{e.message})"
    end

    def runner_class(klass)
      KB::RunnerPlugin.const_get(klass)
    end

    def gem_from_path(plugin_path)
      local_gem_path = "#{File.expand_path(plugin_path, $LOAD_PATH.first)}"
      local_gemspec = File.join(File.dirname($LOAD_PATH.first), "kb.gemspec")

      if ! Dir.glob("#{local_gem_path}#{Gem.suffix_pattern}").empty?
        Gem::Specification.load(File.expand_path(local_gemspec))
      else
        Gem::Specification.find_by_path(plugin_path)
      end
    end
  end
end
