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

# provide a command base class for subcommands
# derived from https://gist.github.com/sss/1903461
begin
  require 'thor'
rescue LoadError
  require 'rubygems'
  require 'thor'
end

module ForjDocker
  module Cli
    module SubCommands
      # provide for a subcommand base class
      class ThorSubCommands < Thor
        class << self
          attr_accessor :long_description

          def subcommand_setup(name, usage, desc = @long_description)
            name = name.to_sym if name.class == String
            namespace name
            @subcommand_usage = usage
            @subcommand_desc = desc
          end

          # for custom banners....
          # def banner(task, _namespace = nil, _subcommand = false)
          #   "#{basename} #{task.formatted_usage(self, true, true)}"
          # end

          def register_to(klass)
            klass.register(self,
                           @namespace,
                           @subcommand_usage,
                           @subcommand_desc)
          end
        end
      end
    end
  end
end
