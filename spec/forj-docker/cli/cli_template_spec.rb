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
$LOAD_PATH << File.join(File.dirname(__FILE__), '..')
require 'spec_helper'
require 'rubygems'

describe 'test forj-docker template template/bp/docker/Dockerfile.node.erb',
         :default => true do
  @dest_dockerfile = ''
  @docker_file_matchers = nil
  before :all do
    @docker_template = 'template/bp/docker/Dockerfile.node.erb'
    @dest_dockerfile = 'spec/fixtures/Dockerfile.testcli'
    @json_string = '{"custom_commands":"RUN whoami > /tmp/test"}'
    @forj_script = <<-EOS
    require 'forj-docker'
    ForjDocker::Cli::ForjDockerThor.start
    EOS
    #
    # test the forj-docker template command using lib loadpath
    #
    @sh = <<-EOS
    ruby1.9.1 -I lib -e "#{@forj_script}" template #{@docker_template} \
                                          #{@dest_dockerfile} \
                                          -c '#{@json_string}'
    EOS
    puts 'running command :'
    puts @sh

    # list or regular expression matches to check the Dockerfile.test file for.
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
    @command_res = command(@sh)
  end
  it 'exit_status' do
    expect(@command_res.exit_status).to eq 0
  end
  it 'should find expression in dockerfile' do
    @docker_processed = File.open(@dest_dockerfile).read.to_s
    @docker_file_matchers.each do |m|
      puts "working on => #{m}"
      expect(@docker_processed).to match(m)
    end
  end
end
