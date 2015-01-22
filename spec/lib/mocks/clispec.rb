#!/usr/bin/env ruby
# encoding: UTF-8

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
#
mocks_dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH << File.join(mocks_dir, '..', '..' 'lib')
require 'forj-docker/common/helpers'
# spec defaults
module CliSpec
  # common defaults
  module InitCommon
    def forj_script
      @forj_script = <<-EOS
      require 'forj-docker'
      ForjDocker::Cli::ForjDockerThor.start
      EOS
      @forj_script
    end

    def spec_bp_name
      'testbp'
    end

    def spec_work_dir
      'spec/fixtures/cli'
    end

    def spec_layout_file
      "#{spec_work_dir}/forj/#{spec_bp_name}-layout.yaml"
    end

    def spec_master_file
      "#{spec_work_dir}/forj/#{spec_bp_name}-master.yaml"
    end

    # a sample layout file
    def layout_contents
      @layout = <<-LAYOUT
  blueprint-deploy:
    layout: #{spec_bp_name} # name of the layout file we use
    blueprint : #{spec_bp_name} # name of the default blueprint
    servers:
      - server1:
        name: util
        applications:
          - app1:
          - app2:
      - server2:
        name: review
        applications:
          - app1:
          - app3:
      LAYOUT
      @layout
    end

    # master yaml configuration file.
    def master_contents
      @master = <<-MASTER
  blueprint:
    name: #{spec_bp_name}
    description: This is for testing purposes
    icon:
      file : test.png
    content : (--- base64 encoded ---)
    documentation : 'http://openstack.org/forj'
    locations:
      modules:
        - src-repo: redstone
          git: https://review.forj.io/p/forj-oss/redstone
          puppet-apply: install
        - src-repo: config
          git: https://review.forj.io/p/oo-infra/config
          puppet-extra-modules: /opt/config/production/git/config/modules
      MASTER
      @master
    end

    include Helpers
    def spec_blueprint_setup
      # remove the layout and master file if they exist
      remove_file spec_layout_file
      remove_file spec_master_file

      # generate the layout and master file.
      ensure_dir_exists spec_work_dir
      create_file layout_contents, spec_layout_file
      create_file master_contents, spec_master_file
    end
  end
  # spec defaults
  module InitDefaults
    include CliSpec::InitCommon
    def spec_init_files_empty
      files = []
      files << 'spec/fixtures/init_empty/Rakefile'
      files << 'spec/fixtures/init_empty/README.md'
      files << 'spec/fixtures/init_empty/docker/review/.gitignore'
      files << 'spec/fixtures/init_empty/docker/review/Dockerfile.review'
      files << 'spec/fixtures/init_empty/docker/review/runit.sh'
      files << 'spec/fixtures/init_empty/docker/review/setup_sources.sh'
      files
    end

    def spec_vanilla_init(work_dir = 'spec/fixtures/vanilla_init')
      @sh = <<-EOS
      set -x -v
      [ ! -d "#{work_dir}" ] && mkdir -p "#{work_dir}"
      _cwd=$(pwd)
      FORJ_DOCKER_LIB=$(pwd)/lib
      cd "#{work_dir}"
      if [ $? -eq 0 ]; then
        ruby1.9.1 -I $FORJ_DOCKER_LIB -e "#{forj_script}" init
        s=$?
      fi
      cd $_cwd
      return $s
      EOS

      @command_res = command(@sh)
      # force execution
      FileUtils.rm_rf work_dir if File.exist?(work_dir)
      PrcLib.debug "exit => #{@command_res.exit_status}"
      if spec_debug
        puts 'running command :'
        puts @sh
        puts "stdout => #{@command_res.stdout}"
        puts "stderr => #{@command_res.stderr}"
        puts 'setup complete'
      end
      File.join(work_dir, 'docker')
    end
  end
  # testing data for cli_template_spec
  module DefaultsTemplate
    include CliSpec::InitCommon
    def docker_template
      @docker_template = 'template/bp/docker/Dockerfile.node.erb'
      @docker_template
    end

    def dest_dockerfile
      @dest_dockerfile = 'spec/fixtures/Dockerfile.testcli'
      @dest_dockerfile
    end

    def docker_file_matchers
      # list or regular expression matches to check
      # the Dockerfile.test file for.
      @docker_file_matchers = [
        /^# DOCKER-VERSION 0.0.1/,
        /^# DOCKER-NAME norepo\/none\:default/,
        /^FROM  forj\/ubuntu\:precise/,
        /^MAINTAINER your name, youremail@yourdomain.com/,
        %r{^WORKDIR /opt/workspace},
        %r{^ADD . /opt/workspace},
        /^EXPOSE 22 80 443/,
        %r{^RUN whoami > /tmp/test}
      ]
      @docker_file_matchers
    end
  end
end
