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
    class ForjDockerThor < Thor  # rubocop:disable ClassLength
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
        require 'cli/commands/version'
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
        require 'cli/commands/init'
        ForjDocker::Commands::Init.new(options).start
      end

      #
      # command: template <erb file> <destination>
      #
      desc 'template <erb file> <destination>',
           'convert a Dockerfile.node.erb to Dockerfile.node.'
      long_desc <<-LONGDESC
      This command will be used durring build time for converting a
      Dockerfile erb template to a real Dockerfile. The configuration for
      the template will have some defaults, as specified for the class
      DockerTemplates, see spec/classes/common/docker_template_spec.rb.

      This command also works with blueprint specifications for forj.  If
      a blueprint is found, we will use the first found blueprint layout
      to initiate default settings that can also be used in the dockerfiles.
      To specifify alternative blueprint layout file, see --layout_name
      option.

      forj-docker will be enhanced for introducing new values with command:
      forj-docker set <param> <value>

      Example:

      forj-docker template template/bp/docker/Dockerfile.node.erb \
                  tmp/Dockerfile.testnode
      LONGDESC

      method_option :config_json,
                    :aliases => '-c',
                    :desc    => 'json string containing values for erb.',
                    :default => '{}'

      method_option :layout_name,
                    :aliases => '-l',
                    :desc    => 'specify an alternative layout name.',
                    :default => 'undef'

      def template(erb_file = nil, dockerfile = nil)
        require 'cli/commands/template'
        ForjDocker::Commands::Template.new(erb_file,
                                           dockerfile,
                                           options
                                          ).start
      end
    end
  end
end
