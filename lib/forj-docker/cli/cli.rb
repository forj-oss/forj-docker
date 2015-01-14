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
require 'forj-docker/cli/sub_commands/configure'
require 'forj-docker/cli/sub_commands/template'

module ForjDocker
  module Cli
    #
    #  cli forj-docker
    class ForjDockerThor < Thor
      class_option :debug,   :aliases => '-d', :desc => 'Set debug mode'
      class_option :verbose, :aliases => '-v', :desc => 'Set verbose mode'
      # class_option :config,  :aliases => '-c', :desc => 'Path to a different
      #                forj config file. By default, use ~/.forj/config.yaml'
      # class_option :libforj_debug,
      #              :desc => 'Set lib-forj debug level verbosity.' + \
      #                'verbosity. 1 to 5. Default is one.'

      # error when task not found.
      def self.exit_on_failure?
        PrcLib.error('command failure with thor')
        true
      end

      # command: version
      # thor manage the help command.
      #
      desc 'help [action]',
           'Describe available FORJ actions or one specific action'
      def help(task = nil, subcommand = false)
        if task
          self.class.task_help(shell, task)
        else
          puts <<-LONGDESC
Welcome to forj-docker !!!
----------------------------------

    forj-docker usage and setup can be found on https://docs.forj.io.
    but here are some shortcuts to get you started!

    1. setup a new project, make sure you start in an empty folder.
    `$ mkdir bpname`
    `$ forj-docker init`

    2. Build it
    `$ rake build`

    3. run it
    `$ rake runit`
    `$ docker ps`

    forj-docker info:
    --------------------------
    Executing from    : #{$RT_GEM_HOME}
    Running version   : #{$RT_VERSION}
    Look for examples : find '#{$RT_GEM_HOME}/template/bpnoop/.'

    forj-docker command line details:
    --------------------------
          LONGDESC
          self.class.help(shell, subcommand)
        end
      end

      #
      # command: version
      # thor manage the version command
      #
      desc 'version', 'get GEM version of forj.'
      def version
        require 'forj-docker/cli/commands/version'
        ForjDocker::Commands::Version.new(options).start
      end

      #
      # command: init
      # thor manage the init command
      #
      desc 'init [options]', 'setup a working example in the current directory.'
      long_desc <<-LONGDESC
      If a forj blueprint can be found in the current directory,
      then we can build the docker work area located in the docker folder.
LONGDESC
      method_option :force,
                    :aliases => '-f',
                    :desc    => 'If files are found they will be overwritten.',
                    :default => false
      def init
        require 'forj-docker/cli/commands/init'
        ForjDocker::Commands::Init.new(options).start
      end

      # These are implemented as sub-commands so
      # we can keep cli simple and understandable.
      ForjDocker::Cli::SubCommands::Template.register_to(self)
      ForjDocker::Cli::SubCommands::Configure.register_to(self)
    end
  end
end
