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
require 'forj-docker/cli/commands/base'

module ForjDocker
  module Commands
    #
    # command: template <erb file> <destination>
    class Template < ForjDocker::Commands::Base
      attr_accessor :erb_file
      attr_accessor :dockerfile

      def initialize(erb_file = nil, dockerfile = nil, options = {}, conf = {})
        @erb_file   = erb_file
        @dockerfile = dockerfile
        super(options, conf)
      end

      def start
        super
        # Lets load blueprint properties if they exist.
        PrcLib.debug 'In Template start'
        blueprint = Blueprint.new
        if blueprint.exist_blueprint?
          blueprint.setup @options[:layout_name]
          @docker_properties = blueprint.properties.merge(@docker_properties)
        end
        DockerTemplate.new.process_dockerfile(File.expand_path(@erb_file),
                                              File.expand_path(@dockerfile),
                                              @docker_properties)
        PrcLib.message('template processed ... %s', dockerfile)
      end

      def check_args
        super
        PrcLib.fatal(1, 'check forj-docker help template.'\
        '  An erb input file is required.') if @erb_file.nil?
        PrcLib.fatal(1, 'check forj-docker help template.  '\
        'Destination docker file' \
        'required.') if @dockerfile.nil?
        PrcLib.debug('using input file => %s', @erb_file)
        PrcLib.debug('using output file => %s', @dockerfile)
        validate_file_andfail @erb_file
        validate_nofile_andwarn @dockerfile
      end
    end
  end
end
