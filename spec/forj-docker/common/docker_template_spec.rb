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
# Test DockerTempate
#
# *Test*
# * test DockerTemplate class
#
spec_dir = File.join(File.expand_path(File.dirname(__FILE__)), '..')
$LOAD_PATH << spec_dir
require 'spec_helper'
require 'rubygems'

$LOAD_PATH << File.join(spec_dir, '..', 'lib')
require 'forj-docker/common/log'
require 'forj-docker/common/docker_template'

describe 'test DockerTemplate class on template/bp/docker/Dockerfile.node.erb',
         :default => true do
  @dest_dockerfile = ''
  @docker_file_matchers = nil
  before :all do
    @dest_dockerfile = 'spec/fixtures/Dockerfile.test'
    #
    # test the DockerTemplate class with some set values
    #
    DockerTemplate.new.process_dockerfile(
      'template/bp/docker/Dockerfile.node.erb',
      @dest_dockerfile,
      :VERSION          => '1.0.1',
      :repo_name        => 'test',
      :blueprint_name   => 'testbp',
      :node             => 'foo',
      :maintainer_name  => 'testco.io',
      :maintainer_email => 'tester.foo@testco.io',
      :custom_commands  => '# just a custom comment'
    )
    # list or regular expression matches to check the Dockerfile.test file for.
    @docker_file_matchers = [
      /^# DOCKER-VERSION 1.0.1/,
      /^# DOCKER-NAME test\/testbp\:foo/,
      /^FROM  forj\/ubuntu\:precise/,
      /^MAINTAINER testco.io, tester.foo@testco.io/,
      %r{^WORKDIR /opt/workspace},
      %r{^ADD . /opt/workspace},
      /^EXPOSE 22 80 443/,
      /^# just a custom comment/
    ]
    @docker_processed = File.open(@dest_dockerfile).read.to_s
  end
  it 'should find expression in dockerfile' do
    @docker_file_matchers.each do |m|
      puts "working on => #{m}"
      expect(@docker_processed).to match(m)
    end
  end
end
