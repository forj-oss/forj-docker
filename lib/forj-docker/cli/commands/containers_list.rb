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
require 'json'
require 'forj-docker/cli/commands/base'
require 'forj-docker/common/docker_template'

module ForjDocker
  module Commands
    #
    # command: containers list
    # list all the containers in a given work area
    class ContainersList < ForjDocker::Commands::Base
      attr_accessor :params
      attr_accessor :docker_files
      attr_accessor :docker_workarea

      def initialize(params, options = {}, conf = {})
        @docker_workarea = options[:docker_workarea]
        super(options, conf)
        @params = params
        # get a list of files from the work area
        # find "docker" -type f \
        # -name 'Dockerfile.*' ! -name '*.erb' ! -name '*.node'
        # get the name, release and maintainer of each docker images
        # populate @docker_files
        PrcLib.debug "docker_workarea => #{@docker_workarea}"
        @docker_files = find_files(/Dockerfile.*/, @docker_workarea)
        @docker_files = filter_files(/.*Dockerfile.*.erb$/, @docker_files)
        @docker_files = filter_files(/.*Dockerfile.*.node$/, @docker_files)
      end

      def start
        super
        PrcLib.debug "config name #{@conf.config_filename}"
        PrcLib.debug("@params => #{@params}")
        # return JSON output of @docker_files
        PrcLib.debug "#{@docker_files}"
        containers_data = { :containers => [] }
        dt = DockerTemplate.new
        @docker_files.each do |df|
          containers_data[:containers] << dt.dockerfile_metadata(df)
        end
        PrcLib.message containers_data.to_json unless @options[:quiet]
        containers_data
      end

      def check_args
        super
        PrcLib.fatal(1, 'check docker work area option.  '\
        "no 'docker' folder found, #{@docker_workarea}." \
        '  use --docker_workarea option or fix path.') if @docker_workarea.nil?
        validate_file_andfail @docker_workarea
      end
    end
  end
end
