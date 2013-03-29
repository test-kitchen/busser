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
require 'busser/command/deserialize'
require 'busser/command/plugin'
require 'busser/command/setup'
require 'busser/command/suite'
require 'busser/command/test'

module Busser

  # Main command line interface class which delegates to subcommands.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  #
  class CLI < Thor::Base

    register Busser::Command::Deserialize, "deserialize",
      "deserialize", "Takes a Base64 file stream and creates a local file"
    tasks["deserialize"].options = Busser::Command::Deserialize.class_options

    register Busser::Command::Setup, "setup",
      "setup", "Creates a Busser home"

    register Busser::Command::Plugin, "plugin",
      "plugin SUBCOMMAND", "Plugin subcommands"

    register Busser::Command::Suite, "suite",
      "suite SUBCOMMAND", "Suite subcommands"

    register Busser::Command::Test, "test",
      "test [PLUGIN ...]", "Runs test suites"
  end
end
