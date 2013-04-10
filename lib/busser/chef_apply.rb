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

require 'busser/chef_ext'

module Busser

  # A modified re-implementation of chef-apply which ships with Chef 11 gems.
  #
  # @author Fletcher Nichol <fnichol@nichol.ca>
  #
  class ChefApply

    def initialize(config = {}, &block)
      @config = { :why_run => false }.merge(config)
      @apply_block = block

      if ! config.has_key?(:file) && ! block_given?
        raise ArgumentError, ":file or block must be given"
      end
    end

    def converge
      as_solo do
        load_recipe
        Chef::Runner.new(run_context).converge
      end
    end

    private

    attr_reader :config, :apply_block

    COOKBOOK_NAME   = "(chef-apply cookbook)".freeze
    COOKBOOK_RECIPE = "(chef-apply recipe)".freeze

    def as_solo
      log_level = Chef::Log.level
      solo_mode = Chef::Config[:solo]
      why_run   = Chef::Config[:why_run]

      Chef::Log.level         = chef_log_level
      Chef::Config[:solo]     = true
      Chef::Config[:why_run]  = config[:why_run]
      yield
    ensure
      Chef::Config[:why_run]  = why_run
      Chef::Config[:solo]     = solo_mode
      Chef::Log.level         = log_level
    end

    def load_recipe
      recipe = Chef::Recipe.new(COOKBOOK_NAME, COOKBOOK_RECIPE, run_context)

      if config[:file]
        recipe.from_file(config[:file].to_s)
      else
        recipe.instance_eval(&apply_block)
      end
    end

    def run_context
      @run_context ||= begin
        if client.events.nil?
          Chef::RunContext.new(client.node, cookbook_collection)
        else
          Chef::RunContext.new(client.node, cookbook_collection, client.events)
        end
      end
    end

    def cookbook_collection
      @cookbook_collection ||= begin
        cookbook = Chef::CookbookVersion.new(COOKBOOK_NAME)
        Chef::CookbookCollection.new({ COOKBOOK_NAME => cookbook })
      end
    end

    def client
      @client ||= begin
        client = Chef::Client.new
        client.run_ohai
        client.load_node
        client.build_node
        client
      end
    end

    def chef_log_level
      (ENV['BUSSER_LOG_LEVEL'] && ENV['BUSSER_LOG_LEVEL'].to_sym) || :info
    end
  end
end
