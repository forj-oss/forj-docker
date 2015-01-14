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
    # command: configure get section::key
    class ConfigureGet < ForjDocker::Commands::Base
      attr_accessor :params

      def initialize(params, options = {}, conf = {})
        super(options, conf)
        @params = params
      end

      def start
        super
        PrcLib.debug "config name #{@conf.sConfigName}"
        PrcLib.debug("@params => #{@params}")
        PrcLib.debug("@params.length => #{@params.length}")
        return if @params.nil?
        return unless @params.length == 1
        key = @params[0]
        PrcLib.debug("key => #{key}")
        key_value = @conf[key]
        PrcLib.message format('%s', key_value)
        key_value
      end

      def check_args
        super
      end
    end
  end
end
