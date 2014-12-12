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
  require 'erb'
  require 'forj-docker/common/log' # Load default loggers
  require 'forj-docker/common/specinfra_helper'
  require 'forj-docker/common/erb_data'
  include Logging
rescue LoadError
  require 'rubygems'
  require 'yaml'
  require 'erb'
  require 'forj-docker/common/log' # Load default loggers
  require 'forj-docker/common/specinfra_helper'
  require 'forj-docker/common/erb_data'
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
      FileUtils.cp_r("#{File.join($RT_GEM_HOME, 'template', 'bpnoop', '.')}",
                     cwd,
                     :verbose => true)
      FileUtils.cp_r("#{File.join($RT_GEM_HOME, 'Vagrantfile')}",
                     cwd,
                     :verbose => true)
    end

    #
    # find all blueprint files
    #
    def find_blueprints
      cwd = File.expand_path('.')
      Dir.entries(File.join(cwd, 'forj'))
        .select { |f| !File.directory? f }
        .select { |f| f =~ /.*-layout.yaml/ }
    end

    #
    # blueprint_nodes
    #
    def find_blueprint_nodes
      nodes = []
      cwd = File.expand_path('.')
      find_blueprints.each do | bps_file |
        blueprint = YAML.load_file(File.join(cwd,
                                             'forj',
                                             bps_file))
        begin
          nodes << blueprint['blueprint-deploy']['servers']
            .map { |n| n['name'] }
        rescue e
          Logger.error(e)
        end
      end
      nodes.flatten.uniq
    end

    #
    # blueprint_name
    #
    def find_blueprint_name
      blueprint_name = 'none'
      cwd = File.expand_path('.')
      find_blueprints.each do | bps_file |
        blueprint = YAML.load_file(File.join(cwd,
                                             'forj',
                                             bps_file))
        begin
          blueprint_name = blueprint['blueprint-deploy']['layout']
        rescue e
          Logger.error(e)
        end
      end
      blueprint_name
    end

    #
    # process docker file erb
    #
    def process_dockerfile(fdocker_erb, fdocker_dest, vals = {})
      erb = ERB.new(File.read(fdocker_erb))
      erb.def_method(ErbData, 'render', fdocker_erb)
      begin
        File.open(fdocker_dest, 'w') do |fw|
          fw.write ErbData.new(vals).render
          fw.close
        end
      rescue StandardError => e
        Logging.error(format('failed to process dockerfile for %s : %s',
                             vals[:node], e.message))
      end
    end

    #
    # Rakefile processing
    #
    def process_rake(fsrc, fdest)
      rake_file = File.join(fdest, 'Rakefile')
      if File.exist? rake_file
        # edit the file
        is_include = false
        File.read(rake_file).each_line do |line|
          if line.downcase =~ %r{require 'forj-docker/tasks/forj-docker'}
            is_include = true
            break
          end
        end
        unless is_include
          File.open("#{rake_file}.tmp", 'w') do |rake_file_tmp|
            File.read(rake_file).each_line do |line|
              if line.downcase =~ /.*require .*/
                rake_file_tmp << "require 'forj-docker/tasks/forj-docker'\n"
                is_include = true
              end
              rake_file_tmp << line
            end
            unless is_include
              rake_file_tmp << "require 'forj-docker/tasks/forj-docker'\n"
            end
          end

          FileUtils.mv("#{rake_file}.tmp", rake_file)
        end
      else
        FileUtils.cp_r(fsrc,
                       fdest,
                       :verbose => true)
      end
    end

    #
    # init_blueprint
    # initialize the current folder based on blueprint layout
    #
    def init_blueprint(docker_data = {})
      docker_data = docker_data.merge(
        :blueprint_name => find_blueprint_name,
        :repo_name => 'forj',
        :VERSION => '0.0.0'
      )
      cwd = File.expand_path('.')
      nodes = find_blueprint_nodes
      if nodes.length > 0
        nodes.each do | node |
          docker_data[:node] = node
          folder = File.join(cwd, 'docker', docker_data[:blueprint_name], node)
          FileUtils.mkdir_p folder unless File.directory?(folder)
          FileUtils.cp_r("#{File.join($RT_GEM_HOME,
                                      'template', 'bp',
                                      'docker', '.')}",
                         folder,
                         :verbose => true)
          # convert the folder/Dockerfile.node.erb to folder/Dockerfile.node
          process_dockerfile(File.join(folder, 'Dockerfile.node.erb'),
                             File.join(folder, "Dockerfile.#{node}"),
                             docker_data)
          FileUtils.rm(File.join(folder, 'Dockerfile.node.erb'))
        end
      else
        Logger.warning('blueprint detected but no nodes found.')
        folder = File.join(cwd, 'docker', blueprint_name)
        FileUtils.mkdir_p folder unless File.directory?(folder)
        FileUtils.cp_r("#{File.join($RT_GEM_HOME,
                                    'template', 'bpnoop',
                                    'docker', '.')}",
                       folder,
                       :verbose => true)
      end

      process_rake(File.join($RT_GEM_HOME, 'template', 'bpnoop', 'Rakefile'),
                   cwd)

      FileUtils.cp_r("#{File.join($RT_GEM_HOME, 'Vagrantfile')}",
                     cwd,
                     :verbose => true) unless File.exist?(
                                              File.join(cwd, 'Vagrantfile'))
    end
  end
end

include ForjDocker::AppInit
forj_initialize
