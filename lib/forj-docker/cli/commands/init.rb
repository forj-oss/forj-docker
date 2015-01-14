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
    # command: init
    class Init < ForjDocker::Commands::Base
      def initialize(options = {}, conf = {})
        super(options, conf)
      end

      def start
        super
        PrcLib.debug 'In Init start'
        if Blueprint.new.exist_blueprint?
          ForjDocker::AppInit.init_blueprint @options, @conf
        else
          ForjDocker::AppInit.init_vanilla @options
        end
        # init should configure the default to be bare sense
        # this should be a docker system
        rake_include_path = $LOAD_PATH.join File::PATH_SEPARATOR
        ruby_exec_cmd = "ruby1.9.1 -I #{rake_include_path} -S"
        rake_exec_cmd = "#{ruby_exec_cmd} rake \"configure[bare]\""
        PrcLib.debug 'Running rake command : '
        PrcLib.debug rake_exec_cmd
        system rake_exec_cmd
        PrcLib.message 'init complete'
        PrcLib.debug 'init complete'
      end

      def check_args
        super
      end
    end
  end
end
