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

require "thor/shell"

module Busser

  # User interface methods.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  #
  module UI

    module_function

    # Thor::Shell's delegated methods are not mixed into this module, so
    # provide the two output primitives it relies on.
    # @param msg [String] text to write to stdout
    # @return [void]
    def say(msg)
      $stdout.puts(msg)
    end

    # @param msg [String] text to write to stderr
    # @return [void]
    def error(msg)
      $stderr.puts(msg)
    end

    # Announces a step, at the top level of the output.
    #
    # @param msg [String] the message
    # @return [void]
    def banner(msg)
      say("-----> #{msg}")
    end

    # Reports detail beneath a banner.
    #
    # @param msg [String] the message
    # @return [void]
    def info(msg)
      say("       #{msg}")
    end

    # Reports something the user should notice but which is not fatal.
    #
    # @param msg [String] the message
    # @return [void]
    def warn(msg)
      say(">>>>>> #{msg}")
    end

    # Reports a failure, on stderr.
    #
    # @param msg [String] the message
    # @return [void]
    def fatal(msg)
      error("!!!!!! #{msg}")
    end

    # Runs a shell command, exiting with a diagnosis if it fails.
    #
    # @param cmd [String] the command line
    # @param config [Hash] options passed through to Thor's runner
    # @return [true] if the command succeeded
    # @see #handle_command
    def run!(cmd, config = {})
      config = { capture: false, verbose: false }.merge(config)

      handle_command("Command", cmd) do
        run(cmd, config)
      end
    end

    # Runs a Ruby script with the current interpreter, exiting with a
    # diagnosis if it fails.
    #
    # @param cmd [String] the script and its arguments
    # @param config [Hash] options passed through to Thor's runner
    # @return [true] if the script succeeded
    # @see #handle_command
    def run_ruby_script!(cmd, config = {})
      config = { capture: false, verbose: false }.merge(config)

      handle_command("Ruby Script", cmd) do
        run_ruby_script(cmd, config)
      end
    end

    # Reports a failure and exits.
    #
    # @param msg [String] the message
    # @param exitstatus [Integer] the status to exit with
    # @return [void] does not return
    def die(msg, exitstatus = 1)
      fatal(msg)
      exit(exitstatus)
    end

    # Wrapped so tests can stub it.
    #
    # @return [Process::Status, nil] the status of the last child process
    def status
      $?
    end

    # Runs a block and turns however the child process ended into a readable
    # message and a matching exit status.
    #
    # Three endings are distinguished because they mean different things to
    # someone reading CI output: a nil status usually means the machine ran out
    # of memory before the child could report; a signal means something killed
    # the run, typically the out of memory killer; and an exit code means the
    # command itself failed.
    #
    # @param type [String] what was run, for the message
    # @param cmd [String] the command line, for the message
    # @yield runs the command
    # @return [true] if the command succeeded
    # @raise [StandardError] re-raised if the block itself raised
    def handle_command(type, cmd)
      begin
        yield
      rescue => e
        fatal(
          "#{type} [#{cmd}] raised an exception: #{e.message}\n" +
          e.backtrace.join("\n")
        )
        raise
      end

      if status.nil?
        die(
          "#{type} [#{cmd}] did not return a valid status. " \
          "This instance could be starved for RAM or may have swap disabled."
        )
      elsif status.success?
        true
      elsif status.exitstatus.nil?
        # A process killed by a signal has no exit status, and Kernel#exit
        # rejects nil, so reporting it as an exit code raised a TypeError and
        # took Busser down with a stack trace rather than a diagnosis. Signals
        # are how the out of memory killer stops a test run, which is the same
        # situation the nil status branch above was written for.
        signal = status.termsig
        die("#{type} [#{cmd}] was terminated by signal #{signal}", 128 + signal)
      else
        code = status.exitstatus
        die("#{type} [#{cmd}] exit code was #{code}", code)
      end
    end
  end
end
