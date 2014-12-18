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
# Test forj-docker template cli
#
# *Test*
# * template standard test
# * test with --debug
# * test with --verbose
spec_dir = File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')
$LOAD_PATH << spec_dir
require 'rubygems'
require 'spec_helper'

$LOAD_PATH << File.join(spec_dir, '..', 'lib')
require 'forj-docker/common/log'
require 'forj-docker/common/docker_template'
require 'forj-docker/common/blueprint'

#
# spec defaults
module CliSpec
  # spec defaults
  module Defaults
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

    def forj_script
      @forj_script = <<-EOS
      require 'forj-docker'
      ForjDocker::Cli::ForjDockerThor.start
      EOS
      @forj_script
    end
  end
end

include CliSpec::Defaults

describe 'cli_template_spec: forj-docker template' \
         ' template/bp/docker/Dockerfile.node.erb',
         :default => true do
  before :all do
    File.delete(dest_dockerfile) if File.exist?(dest_dockerfile)

    @json_string = '{"custom_commands":"RUN whoami > /tmp/test"}'
    #
    # test the forj-docker template command using lib loadpath
    #
    @sh = <<-EOS
    ruby1.9.1 -I lib -e "#{forj_script}" template #{docker_template} \
                                          #{dest_dockerfile} \
                                          -c '#{@json_string}'
    EOS
    puts 'running command :'
    puts @sh

    @command_res = command(@sh)
    # force execution
    puts "exit => #{@command_res.exit_status}"
    @docker_processed = File.open(dest_dockerfile).read.to_s
  end

  #
  # the default should work without errors
  #
  it 'exit_status' do
    expect(@command_res.exit_status).to eq 0
  end

  #
  # we should get a processed file
  #
  it 'should find expression in dockerfile' do
    docker_file_matchers.each do |m|
      expect(@docker_processed).to match(m)
    end
  end
end

describe 'cli_template_spec: cli --debug', :default => true do
  before :all do
    File.delete(dest_dockerfile) if File.exist?(dest_dockerfile)
    @json_string = '{"custom_commands":"RUN whoami > /tmp/test"}'
    @sh = <<-EOS
    ruby1.9.1 -I lib -e "#{forj_script}" template #{docker_template} \
                                          #{dest_dockerfile} \
                                          -c '#{@json_string}' --debug
    EOS
    puts 'running command :'
    puts @sh

    @command_res = command(@sh)
    # force execution
    puts "exit => #{@command_res.exit_status}"
    @docker_processed = File.open(dest_dockerfile).read.to_s
  end
  #
  # the default should work without errors
  #
  it 'exit_status' do
    expect(@command_res.exit_status).to eq 0
  end

  #
  # if we run it again, it should work with debug options
  #
  it 'should execute forj-docker templates with --debug' do
    expect(@command_res.exit_status).to eq 0
    docker_file_matchers.each do |m|
      expect(@docker_processed).to match(m)
    end
  end
end

describe 'cli_template_spec: cli --verbose', :default => true do
  before :all do
    File.delete(dest_dockerfile) if File.exist?(dest_dockerfile)
    @json_string = '{"custom_commands":"RUN whoami > /tmp/test"}'
    @sh = <<-EOS
    ruby1.9.1 -I lib -e "#{forj_script}" template #{docker_template} \
                                          #{dest_dockerfile} \
                                          -c '#{@json_string}' --verbose
    EOS
    puts 'running command :'
    puts @sh

    @command_res = command(@sh)
    # force execution
    puts "exit => #{@command_res.exit_status}"
    @docker_processed = File.open(dest_dockerfile).read.to_s
  end
  #
  # the default should work without errors
  #
  it 'exit_status' do
    expect(@command_res.exit_status).to eq 0
  end

  #
  # if we run it again, it should work with debug options
  #
  it 'cli_template_spec: should execute forj-docker templates with --verbose' do
    expect(@command_res.exit_status).to eq 0
    docker_file_matchers.each do |m|
      expect(@docker_processed).to match(m)
    end
  end
end
