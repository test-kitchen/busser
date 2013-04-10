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

require 'chef/client'
require 'chef/providers'
require 'chef/resources'
require 'chef/cookbook_version'

class Chef
  class Client
    attr_reader :events
  end

  # https://github.com/sometimesfood/sandwich/commit/d3540feade873929daaf78312d30a6729eb00bc3

  # Chef::CookbookVersion, monkey patched to use simpler file source
  # paths (always uses local files instead of manifest records)
  class CookbookVersion
    # Determines the absolute source filename on disk for various file
    # resources from their relative path
    #
    # @param [Chef::Node] node the node object, ignored
    # @param [Symbol] segment the segment of the current resource, ignored
    # @param [String] source the source file path
    # @param [String] target the target file path, ignored
    # @return [String] the preferred source filename
    def preferred_filename_on_disk_location(node, segment, source, target = nil)
      # keep absolute paths, convert relative paths into absolute paths
      source.start_with?('/') ? source : File.join(Dir.getwd, source)
    end
  end
end
