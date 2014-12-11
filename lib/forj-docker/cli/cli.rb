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

module ForjDocker
  module Cli
    #
    #  cli forj-docker
    class ForjDockerThor < Thor
      # TODO: talk with chris to find out how these are intended to work
      # class_option :debug,   :aliases => '-d', :desc => 'Set debug mode'
      # class_option :verbose, :aliases => '-v', :desc => 'Set verbose mode'
      # class_option :config,  :aliases => '-c', :desc => 'Path to a different
      #                forj config file. By default, use ~/.forj/config.yaml'
      # class_option :libforj_debug,
      #              :desc => 'Set lib-forj debug level verbosity.' + \
      #                'verbosity. 1 to 5. Default is one.'

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

          2. run it
          `$ rake runit`
          `$ docker ps`

          forj-docker info:
          --------------------------
          Executing from    : #{$RT_GEM_HOME}
          Running version   : #{$RT_VERSION}
          Look for examples : find '#{$RT_GEM_HOME}/test/bpnoop/.'

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
        return unless Gem.loaded_specs['forj-docker']
        gem_version = Gem.loaded_specs['forj-docker'].version.to_s
        Logging.debug(format("Running cli command '%s'", gem_version))
        puts gem_version
      end

      #
      # command: init
      # thor manage the init command
      #
      desc 'init', 'setup a working example in the current directory.'
      def init
        if exist_blueprint?
          ForjDocker::AppInit.init_blueprint
        else
          ForjDocker::AppInit.init_vanilla
        end
        # init should configure the default to be bare sense
        # this should be a docker system
        system("rake \"configure[bare]\"")
        puts 'init complete'
        Logging.debug 'init complete'
      end
    end
  end
end
