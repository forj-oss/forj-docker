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
  require 'yaml'
  require 'common/log.rb' # Load default loggers
  require 'common/specinfra_helper'
  include Logging
rescue LoadError
  require 'rubygems'
  require 'yaml'
  require 'common/log.rb' # Load default loggers
  require 'common/specinfra_helper'
end

module ForjDocker
  #
  # initialize
  module AppInit
    def forj_initialize
      # Defining Global variables
      $RT_GEM_HOME = File.expand_path(File.join(__FILE__,
                                                '..',
                                                '..',
                                                '..',
                                                '..'))
      $RT_GEM_BIN = File.join($RT_GEM_HOME, 'bin')
      $RT_VERSION_SPEC = File.join($RT_GEM_HOME, 'VERSION')
      sh = <<-EOS
      cat '#{$RT_VERSION_SPEC}'
      EOS
      $RT_VERSION = command(sh).stdout.to_s

      $FORJ_DATA_PATH  = File.expand_path(File.join(gethome_path,
                                                    '.config',
                                                    'forj-docker'))
      $FORJ_CREDS_PATH = File.expand_path(File.join(gethome_path,
                                                    '.cache',
                                                    'forj-docker'))
      $FORJ_TEMP       = File.expand_path(File.join(gethome_path,
                                                    '.config',
                                                    'forj-docker',
                                                    'temp'))

      ensure_dir_exists($FORJ_DATA_PATH)
      ensure_dir_exists($FORJ_CREDS_PATH)
      ensure_dir_exists($FORJ_TEMP)

      $FORJ_LOGGER     = ForjLog.new
    end

    def ensure_dir_exists(path)
      return if dir_exists?(path)
      FileUtils.mkpath(path) unless File.directory?(path)
    end

    #
    # exist_blueprint?
    # check to see if we have a blueprint config file
    #
    def exist_blueprint?
      cwd = File.expand_path('.')
      Logging.debug(format("checking for blueprints '%s'",
                           cwd))
      return false unless File.directory?(File.join(cwd, 'forj'))
      bps = Dir.entries(File.join(cwd, 'forj'))
            .select { |f| !File.directory? f }
            .select { |f| f =~ /.*-layout.yaml/ }
      Logging.debug(format("found files '%s'", bps))
      true
    end

    #
    # init_vanilla
    # initialize the current folder with the vanilla examples
    #
    def init_vanilla
      cwd = File.expand_path('.')
      Logging.debug(format("Running init vanilla command for folder '%s'",
                           cwd))
      puts "init is creating sample here: #{cwd}"
      FileUtils.cp_r("#{File.join($RT_GEM_HOME, 'test', 'bpnoop', '.')}",
                     cwd,
                     :verbose => true)
      FileUtils.cp_r("#{File.join($RT_GEM_HOME, 'Vagrantfile')}",
                     cwd,
                     :verbose => true)
    end

    #
    # init_blueprint
    # initialize the current folder based on blueprint layout
    #
    def init_blueprint
      cwd = File.expand_path('.')
      bps = Dir.entries(File.join(cwd, 'forj'))
            .select { |f| !File.directory? f }
            .select { |f| f =~ /.*-layout.yaml/ }
      blueprint = YAML.load_file(File.join(cwd,
                                           'forj',
                                           bps[0]))
      nodes = blueprint['blueprint-deploy']['servers'].map { |n| n['name'] }
      Logger.debug("working on nodes => #{nodes}")

      nodes.each do | node |
        folder = File.join(cwd, 'docker', node)
        FileUtils.mkdir_p folder unless File.directory?(folder)
        FileUtils.cp_r("#{File.join($RT_GEM_HOME,
                                    'test', 'bpnoop',
                                    'docker', 'review', '.')}",
                       folder,
                       :verbose => true)
      end
      FileUtils.cp_r("#{File.join($RT_GEM_HOME,
                                  'test', 'bpnoop', 'Rakefile')}",
                     cwd,
                     :verbose => true)
      FileUtils.cp_r("#{File.join($RT_GEM_HOME, 'Vagrantfile')}",
                     cwd,
                     :verbose => true)
    end
  end
end
include ForjDocker::AppInit
forj_initialize
