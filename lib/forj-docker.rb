# (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
# load relative libs
begin
  require 'yaml'
  require 'lorj'
rescue LoadError
  require 'rubygems'
  require 'yaml'
  require 'lorj'
end
require 'forj-docker/common/specinfra_helper'
require 'forj-docker/cli/appinit'
require 'forj-docker/cli/cli'

#
# forj-docker cli entry point
#
module ForjDocker
  PrcLib.debug(format("Running forj-docker cli version '%s'",
                      $RT_VERSION))
end
