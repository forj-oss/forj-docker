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
        unless Gem.loaded_specs['forj-docker']
          Logging.warning('Running from source, gem is not loaded')
          return
        end
        gem_version = Gem.loaded_specs['forj-docker'].version.to_s
        Logging.debug(format("Running cli command '%s'", gem_version))
        Logging.message(gem_version)
      end

      #
      # command: init
      # thor manage the init command
      #
      desc 'init', 'setup a working example in the current directory.' \
                   ' If a forj blueprint can be found in the current ' \
                   ' directory, then we can build the docker work '    \
                   ' area located in the docker folder.'
      def init
        if Blueprint.new.exist_blueprint?
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
        process_options options

        Logging.fatal(1, 'check forj-docker help template.'\
                          '  An erb input file is required.') if erb_file.nil?
        Logging.fatal(1, 'check forj-docker help template.  '\
                          'Destination docker file' \
                          'required.') if dockerfile.nil?
        Logging.debug(format('using input file => %s', erb_file))
        Logging.debug(format('using output file => %s', dockerfile))
        validate_file_andfail erb_file
        validate_nofile_andwarn dockerfile
        Logging.debug "options => #{options}"
        Logging.debug "config_json => #{options[:config_json]}"

        docker_properties = options[:config_json].to_data
        # Lets load blueprint properties if they exist.
        blueprint = Blueprint.new
        if blueprint.exist_blueprint?
          blueprint.setup options[:layout_name]
          docker_properties = blueprint.properties.merge(docker_properties)
        end
        DockerTemplate.new.process_dockerfile(
          File.expand_path(erb_file),
          File.expand_path(dockerfile),
          docker_properties
        )
        Logging.message(format('template processed ... %s', dockerfile))
      end
    end
  end
end
