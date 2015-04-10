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
require 'forj-docker/cli/sub_commands/subtemplate'

module ForjDocker
  module Cli
    module SubCommands
      #
      #  containers sub commands
      class Containers < ThorSubCommands
        self.long_description = <<-LONGDESC
      commands to manage containers for forj-docker

      Containers management can be used from rake or forj-docker cli.
      Use this command to publish, pull and list containers that you
      have built with forj-docker.  The containers to manage require
      a docker workarea.  There we will look for Dockerfiles that
      container the docker metadata required to build images that are
      grouped into blueprints.

        - containers list, can list all containers found in docker workarea.
        - containers push, can publish all containers in the docker workarea.
        - containers pull, can pull all containers in the docker workarea.

        LONGDESC
        subcommand_setup 'containers',
                         'containers [command]'
        # command: list
        # list the containers in docker work area
        #
        method_option :docker_workarea,
                      :aliases => '-w',
                      :desc    => 'docker workarea to evaluate.',
                      :default => DockerTemplate.new.default_workarea

        method_option :quiet,
                      :aliases => '-q',
                      :desc    => 'silence all output.',
                      :default => false
        desc 'list',
             'list the containers in the docker workarea'
        long_desc <<-LONGDESC
      get a full list of all the containers found in the docker workarea.
      It doesn't matter if they are published or not.  If publishing we
      you should have built the containers at least once.

      Example:
      forj-docker containers list
LONGDESC
        def list
          require 'forj-docker/cli/commands/containers_list'
          ForjDocker::Commands::ContainersList.new([], options).start
        end

        default_task :list
      end
    end
  end
end
