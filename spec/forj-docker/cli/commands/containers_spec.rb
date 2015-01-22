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

# Test ::ForjDocker::Commands::ContainersPush
# Test ::ForjDocker::Commands::ContainersPull

# *Test*
spec_dir = File.join(File.expand_path(File.dirname(__FILE__)), '..', '..', '..')
$LOAD_PATH << spec_dir
require 'spec_helper'
require 'rubygems'

$LOAD_PATH << File.join(spec_dir, '..', 'lib')
$LOAD_PATH << File.join(spec_dir, '..', 'lib', 'forj-docker')
#
# setup default settings
require 'lorj'
require 'forj-docker/common/hash_helper.rb'
require 'forj-docker/common/settings'
require 'forj-docker/common/helpers'

#
# object under test
require 'cli/commands/containers_push'
require 'cli/commands/containers_pull'
require 'cli/commands/containers_list'

#
# test data
require 'lib/mocks/clispec'
include CliSpec::InitDefaults

# create list but don't actually push, use :test option
describe 'containers can execute from test work_area', :default => true do
  options   = {}
  before :all do
    docker_workarea = spec_vanilla_init
    options = { :test => true, :docker_workarea => docker_workarea }
  end

  it 'should push a mock work_area' do
    containers = nil
    result = false
    # rubocop:disable all
    expect {  # TODO: need to find the disable command for single line blocks.
      containers = ForjDocker::Commands::ContainersPush.new([], options)
    }.not_to raise_error
    # rubocop:enable all
    expect { result = containers.start }.not_to raise_error
    expect(result).to be true
  end

  it 'should pull a mock work_area' do
    containers = nil
    result = false
    # rubocop:disable all
    expect {  # TODO: need to find the disable command for single line blocks.
      containers = ForjDocker::Commands::ContainersPull.new([], options)
    }.not_to raise_error
    # rubocop:enable all
    expect { result = containers.start }.not_to raise_error
    expect(result).to be true
  end

  it 'should list a mock work_area' do
    containers = nil
    result = false
    # rubocop:disable all
    expect {  # TODO: need to find the disable command for single line blocks.
      containers = ForjDocker::Commands::ContainersList.new([], options)
    }.not_to raise_error
    # rubocop:enable all
    expect { result = containers.start }.not_to raise_error
    expect(result[:containers].length).to eq 1
  end
end
