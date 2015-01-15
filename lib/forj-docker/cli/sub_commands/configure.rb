# encoding: UTF-8

# (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

# Base Logging system started and loaded.
begin
  require 'thor'
rescue LoadError
  require 'rubygems'
  require 'thor'
end
require 'cli/sub_commands/subtemplate'

module ForjDocker
  module Cli
    module SubCommands
      #
      #  configure sub commands
      class Configure < ThorSubCommands
        self.long_description = <<-LONGDESC
      commands to configure forj-docker

      This task offers us the ability to configure forj-docker and rake
      specific runtime settings.  These could potentially include settings
      for the purposes of:

        - manage docker configuration
        - manage metadata passed to docker at startup in --env values
        - manage environment options that will be used durring docker build.

        LONGDESC
        subcommand_setup 'configure',
                         'configure [command]'
        # command: get
        # get a configuration value
        #
        desc 'get [section::key]',
             'get a configuration value'
        long_desc <<-LONGDESC
      get the configuration value for a key.
      If no value is set, then the default will be returned.

      Example:
      forj-docker configure get registry_url
LONGDESC
        def get(*params)
          require 'cli/commands/configure_get'
          ForjDocker::Commands::ConfigureGet.new(params, options).start
        end

        #
        # command: configure set section::key=value key=value ...
        desc 'set [key=name] [...] [options]',
             'configure one or more settings.'
        long_desc <<-LONGDESC
      The command configures global settings for forj-docker cli and rake
      command specs that will interact.  Use this command to list available
      configuration and current values.

      registry_url - will provide an alternate docker registry setting.
        LONGDESC
        def set(*params)
          require 'cli/commands/configure_set'
          ForjDocker::Commands::ConfigureSet.new(params, options).start
        end
        # FYI: we can make a task default with this command
        # default_task :set
      end
    end
  end
end
