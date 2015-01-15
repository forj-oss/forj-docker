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

module ForjDocker
  module Commands
    #
    # command: template <erb file> <destination>
    class Base
      attr_accessor :options
      attr_accessor :conf
      attr_accessor :docker_properties

      def initialize(options = {}, _conf = {})
        @options    = options
        # TODO: figure out how we can merge conf with @conf
        @conf       = Lorj::Config.new
        @docker_properties = {}
        Settings.common_options(@options)
        check_args
      end

      def start
        PrcLib.debug "In Base #{@options.sym_keys.keys}"
        return unless @options.sym_keys.key?(:config_json)
        PrcLib.debug "config_json => #{@options[:config_json]}"
        @docker_properties = @options[:config_json].to_data
        PrcLib.debug 'Exiting Base'
      end

      def check_args
        PrcLib.debug "options => #{@options}"
        PrcLib.debug "config_json => #{@options[:config_json]}"
      end
    end
  end
end
