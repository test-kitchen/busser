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

require 'busser/runner_plugin'

# Dummy runner plugin for Busser.
#
# @author Fletcher Nichol <fnichol@nichol.ca>
#
class Busser::RunnerPlugin::Dummy < Busser::RunnerPlugin::Base

  # Example postinstall block that will be executed after the plugin is
  # installed. All Thor actions, and Busser::Helper methods are available for
  # use.
  #
  postinstall do
    # ensure that dummy_path gets pulled into the chef_apply block closure,
    # otherwise the Chef will not understand dummy_path in its run context
    dummy_path = suite_path("dummy").to_s

    # expensive operation delegating a directory creation to Chef, but imagine
    # using resources such as package, remote_file, etc.
    chef_apply do
      directory(dummy_path) { recursive true }
    end

    # create a dummy file
    create_file("#{dummy_path}/foobar.txt", "The Dummy Driver.")
  end

  def test
    banner "[dummy] Running"
    if File.exists?(File.join(suite_path("dummy"), "foobar.txt"))
      info "[dummy] The postinstall script has been called"
    else
      warn "[dummy] The postinstall script was not called"
    end
  end
end
