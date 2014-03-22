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

require 'thor/shell'

module Busser

  # User interface methods.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  #
  module UI

    module_function

    def banner(msg)
      say("-----> #{msg}")
    end

    def info(msg)
      say("       #{msg}")
    end

    def warn(msg)
      say(">>>>>> #{msg}")
    end

    def run!(cmd)
      run(cmd, :capture => false, :verbose => false)

      if status.success?
        true
      else
        code = status.exitstatus
        die "Command [#{cmd}] exit code was #{code}", code
      end
    end

    def run_ruby_script!(cmd, config = {})
      config = { :capture => false, :verbose => false }.merge(config)
      run_ruby_script(cmd, config)

      if status.success?
        true
      else
        code = status.exitstatus
        die "Ruby Script [#{cmd}] exit code was #{code}", code
      end
    end

    def die(msg, exitstatus = 1)
      $stderr.puts(msg)
      exit(exitstatus)
    end

    def status
      $?
    end
  end
end
