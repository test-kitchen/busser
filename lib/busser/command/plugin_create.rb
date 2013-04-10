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

require 'busser'
require 'busser/thor'

module Busser

  module Command

    # Plugin create command.
    #
    # @author Fletcher Nichol <fnichol@nichol.ca>
    #
    class PluginCreate < Busser::Thor::BaseGroup

      argument :name, :type => :string

      class_option :type, :aliases => "-t", :type => :string,
        :default => 'runner', :desc => "Type of plugin (runner)"

      class_option :license, :aliases => "-l", :default => "apachev2",
        :desc => "License type for gem (apachev2, mit, lgplv3, reserved)"

      def create
        self.class.source_root(Busser.source_root.join("templates", "plugin"))

        create_core_files
        create_source_files
        create_features_files
        initialize_git
      end

      private

      def create_core_files
        empty_directory(target_dir)

        create_template("CHANGELOG.md.erb", "CHANGELOG.md")
        create_template("Gemfile.erb", "Gemfile")
        create_template("Rakefile.erb", "Rakefile")
        create_template("README.md.erb", "README.md")
        create_template("gemspec.erb", "#{config[:gem_name]}.gemspec")
        create_template("license_#{config[:license]}.erb", license_filename)
        create_template("gitignore.erb", ".gitignore")
        create_template("tailor.erb", ".tailor")
        create_template("travis.yml.erb", ".travis.yml")
        create_file(File.join(target_dir, ".cane"))
      end

      def create_source_files
        empty_directory(File.join(target_dir, "lib/busser", name))
        empty_directory(File.join(target_dir, "lib/busser/runner_plugin"))

        create_template(
          "version.rb.erb",
          "lib/busser/#{name}/version.rb"
        )
        create_template(
          "runner_plugin.rb.erb",
          "lib/busser/runner_plugin/#{name}.rb"
        )
      end

      def create_features_files
        empty_directory(File.join(target_dir, "features/support"))

        create_template(
          "features_env.rb.erb",
          "features/support/env.rb"
        )
        create_template(
          "features_plugin_install_command.feature.erb",
          "features/plugin_install_command.feature"
        )
        create_template(
          "features_plugin_list_command.feature.erb",
          "features/plugin_list_command.feature"
        )
        create_template(
          "features_test_command.feature.erb",
          "features/test_command.feature"
        )
      end

      def initialize_git
        inside(target_dir) do
          run("git init")
          run("git add .")
        end
      end

      def create_template(erb, dest)
        template(erb, File.join(target_dir, dest), config)
      end

      def target_dir
        File.join(Dir.pwd, "busser-#{name}")
      end

      def config
        @config ||= begin
          type_klass_name = "#{::Thor::Util.camel_case(options[:type])}Plugin"

          {
            :name => name,
            :gem_name => "busser-#{name}",
            :gemspec => "busser-#{name}.gemspec",
            :klass_name => ::Thor::Util.camel_case(name),
            :type => options[:type],
            :type_klass_name => type_klass_name,
            :constant_name => ::Thor::Util.snake_case(name).upcase,
            :author => author,
            :email => email,
            :license => options[:license],
            :license_string => license_string,
            :year => Time.now.year,
          }
        end
      end

      def author
        git_user_name = %x{git config user.name}.chomp
        git_user_name.empty? ? "TODO: Write your name" : git_user_name
      end

      def email
        git_user_email = %x{git config user.email}.chomp
        git_user_email.empty? ? "TODO: Write your email" : git_user_email
      end

      def license_string
        case options[:license]
        when "mit" then "MIT"
        when "apachev2" then "Apache 2.0"
        when "lgplv3" then "LGPL 3.0"
        when "reserved" then "All rights reserved"
        else
          raise ArgumentError, "No such license #{options[:license]}"
        end
      end

      def license_filename
        case options[:license]
        when "mit" then "LICENSE.txt"
        when "apachev2", "reserved" then "LICENSE"
        when "lgplv3" then "COPYING"
        else
          raise ArgumentError, "No such license #{options[:license]}"
        end
      end

      def license_comment
        @license_comment ||= IO.read(File.join(target_dir, license_filename)).
          gsub(/^/, '# ').gsub(/\s+$/, '')
      end
    end
  end
end
