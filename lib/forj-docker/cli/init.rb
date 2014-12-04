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
  require 'serverspec'
  include SpecInfra::Helper::Exec
  include SpecInfra::Helper::DetectOS
  require 'common/log.rb' # Load default loggers
  include Logging
rescue LoadError
  require 'rubygems'
  require 'serverspec'
  include SpecInfra::Helper::Exec
  include SpecInfra::Helper::DetectOS
  require 'common/log.rb' # Load default loggers
end

module ForjDocker
  module Init
    def forj_initialize

      # Defining Global variables
      $RT_GEM_HOME= File.expand_path(File.join(__FILE__,"..","..","..",".."))
      $RT_GEM_BIN = File.join($RT_GEM_HOME,"bin")
      $RT_VERSION_SPEC = File.join($RT_GEM_HOME,"VERSION")
      sh = <<-EOS
      cat '#{$RT_VERSION_SPEC}'
      EOS
      $RT_VERSION = command(sh).stdout.to_s

      $FORJ_DATA_PATH  = File.expand_path(File.join(get_home_path, '.config', 'forj-docker'))
      $FORJ_CREDS_PATH = File.expand_path(File.join(get_home_path, '.cache',  'forj-docker'))
      $FORJ_TEMP       = File.expand_path(File.join(get_home_path, '.config', 'forj-docker', 'temp'))

      ForjDocker::Init::ensure_dir_exists($FORJ_DATA_PATH)
      ForjDocker::Init::ensure_dir_exists($FORJ_CREDS_PATH)
      ForjDocker::Init::ensure_dir_exists($FORJ_TEMP)

      $FORJ_LOGGER     = ForjLog.new()
    end

    def ensure_dir_exists(path)
      if not dir_exists?(path)
        FileUtils.mkpath(path) if not File.directory?(path)
      end
    end
  end
end
include ForjDocker::Init
forj_initialize
