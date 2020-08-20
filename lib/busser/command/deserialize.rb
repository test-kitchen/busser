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

require 'base64' unless defined?(Base64)
require 'digest' unless defined?(Digest)

require 'busser/thor'

module Busser

  module Command

    # Deserialize command.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    #
    class Deserialize < Busser::Thor::BaseGroup

      class_option :destination, :desc => "Destination file path"

      class_option :md5sum, :desc => "MD5 digest of original file"

      class_option :perms, :desc => "Unix permissions on destination file"

      def perform
        file = File.expand_path(options[:destination])
        contents = Base64.decode64(STDIN.read)

        FileUtils.mkdir_p(File.dirname(file))
        File.open(file, "wb") { |f| f.write(contents) }
        FileUtils.chmod(Integer(options[:perms]), file)

        if Digest::MD5.hexdigest(contents) != options[:md5sum]
          abort "Streamed file #{file} does not match source file md5"
        end
      end
    end
  end
end
