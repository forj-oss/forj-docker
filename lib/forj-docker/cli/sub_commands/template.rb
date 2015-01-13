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
      #  manage Docker files as templates
      class Template < ThorSubCommands
        #
        # command: template <erb file> <destination>
        #
        self.long_description = <<-LONGDESC
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
        subcommand_setup 'template', 'template <erb file> <destination>'

        method_option :config_json,
                      :aliases => '-c',
                      :desc    => 'json string containing values for erb.',
                      :default => '{}'

        method_option :layout_name,
                      :aliases => '-l',
                      :desc    => 'specify an alternative layout name.',
                      :default => 'undef'

        desc 'template <erb file> <destination>',
             'Convert a Dockerfile.node.erb to Dockerfile.node.'
        def template(erb_file = nil, dockerfile = nil)
          require 'cli/commands/template'
          ForjDocker::Commands::Template.new(erb_file,
                                             dockerfile,
                                             options).start
        end
        default_task :template
      end
    end
  end
end
