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
  require 'forj-docker/common/log' # Load default loggers
  require 'forj-docker/common/json_helper'
  require 'forj-docker/common/specinfra_helper'
  require 'forj-docker/common/erb_data'
  require 'forj-docker/common/docker_template'
  require 'forj-docker/common/blueprint'
  include Logging
rescue LoadError
  require 'rubygems'
  require 'yaml'
  require 'forj-docker/common/log' # Load default loggers
  require 'forj-docker/common/json_helper'
  require 'forj-docker/common/specinfra_helper'
  require 'forj-docker/common/erb_data'
  require 'forj-docker/common/docker_template'
  require 'forj-docker/common/blueprint'
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

    #
    # process options
    #
    def process_options(options = [])
      Logging.setlevel(Logger::INFO)  if options[:verbose]
      Logging.setlevel(Logger::DEBUG) if options[:debug]
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

    # generate a docker file based on blueprint config for every node.
    #
    #
    def gen_blueprint_docker(blueprint_props = {}, cwd = File.expand_path('.'))
      if blueprint_props[:nodes].length > 0
        blueprint_props[:nodes].each do | node |
          blueprint_props[:node] = node
          folder = File.join(cwd, 'docker', blueprint_props[:name], node)
          unless File.exist?(File.join(folder, "Dockerfile.#{node}.erb"))
            FileUtils.mkdir_p folder unless File.directory?(folder)
            FileUtils.cp_r("#{File.join($RT_GEM_HOME,
                                        'template', 'bp',
                                        'docker', '.')}",
                           folder,
                           :verbose => true)
            FileUtils.cp_r(File.join(folder, 'Dockerfile.node.erb'),
                           File.join(folder, "Dockerfile.#{node}.erb"),
                           :verbose => true)
            # cleanup the node.erb file
            FileUtils.rm(File.join(folder, 'Dockerfile.node.erb'),
                         :force => true)
          end
          # convert the folder/Dockerfile.node.erb to folder/Dockerfile.node
          DockerTemplate.new.process_dockerfile(
            File.join(folder, "Dockerfile.#{node}.erb"),
            File.join(folder, "Dockerfile.#{node}"),
            blueprint_props.merge(:node => node)
          )
        end
      else
        Logger.warning('blueprint detected but no nodes found.')
        folder = File.join(cwd, 'docker', blueprint_props[:name])
        FileUtils.mkdir_p folder unless File.directory?(folder)
        FileUtils.cp_r("#{File.join($RT_GEM_HOME,
                                    'template', 'bpnoop',
                                    'docker', '.')}",
                       folder,
                       :verbose => true)
      end
    end

    # initialize the current folder based on blueprint layout
    #
    def init_blueprint(docker_data = {},
                       cwd = File.expand_path('.'))
      docker_data = {
        :work_dir         => File.join(cwd, 'forj'),
        :repo_name        => 'forj',
        :VERSION          => '1.0.1',
        :maintainer_name  => 'forj.io',
        :maintainer_email => 'cdkdev@groups.hp.com'
      }.merge(docker_data)
      @blueprint = Blueprint.new docker_data
      @blueprint.setup
      # VERSION is all caps here, make lowercase version the same.
      @blueprint.properties[:version] = @blueprint.properties[:VERSION]
      gen_blueprint_docker @blueprint.properties, cwd

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
