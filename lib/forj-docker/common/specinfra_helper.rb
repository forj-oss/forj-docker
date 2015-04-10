#!/usr/bin/env ruby
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

# use specinfra gem to run commands

require 'specinfra'
require 'specinfra/helper/set'
include Specinfra::Helper::Set
set :backend, :exec

#
# command - execute a local command
#
module SpecInfraHelper
  def command(cmd, opts = {})
    runner = Specinfra::Runner
    runner.run_command(cmd, opts)
  end
end
include SpecInfraHelper
