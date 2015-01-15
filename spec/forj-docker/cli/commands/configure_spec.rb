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

# Test ::ForjDocker::Commands::ConfigureGet
# Validate that getting values from config works

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

#
# object under test
require 'cli/commands/configure_get'
require 'cli/commands/configure_set'

describe 'configure_get can get default value', :default => true do
  before :all do
    config_file = File.join(PrcLib.data_path, 'config.yaml')
    FileUtils.rm_rf config_file if File.exist?(config_file)
  end

  it 'should get registry_url default value' do
    confget = nil
    key_val = nil
    # rubocop:disable all
    expect {  # TODO: need to find the disable command for single line blocks.
      confget = ForjDocker::Commands::ConfigureGet.new(['registry_url'])
    }.not_to raise_error
    # rubocop:enable all
    expect { key_val = confget.start }.not_to raise_error
    expect(key_val).to eq 'docker'
  end

  it 'should set registry_url value to foo' do
    confset = nil
    confget = nil
    key_val = nil
    # rubocop:disable all
    expect {  # TODO: need to find the disable command for single line blocks.
      confset = ForjDocker::Commands::ConfigureSet.new(['registry_url=foo'])
      confset.start
    }.not_to raise_error
    expect {  # TODO: need to find the disable command for single line blocks.
      confget = ForjDocker::Commands::ConfigureGet.new(['registry_url'])
    }.not_to raise_error
    # rubocop:enable all
    expect { key_val = confget.start }.not_to raise_error
    expect(key_val).to eq 'foo'
  end

  it 'should set registry_url to empty' do
    confset = nil
    confget = nil
    key_val = nil
    # rubocop:disable all
    expect {  # TODO: need to find the disable command for single line blocks.
      confset = ForjDocker::Commands::ConfigureSet.new(['registry_url=foo'])
      confset.start
    }.not_to raise_error
    expect {  # TODO: need to find the disable command for single line blocks.
      confset = ForjDocker::Commands::ConfigureSet.new(['registry_url='])
      confset.start
    }.not_to raise_error
    expect {  # TODO: need to find the disable command for single line blocks.
      confget = ForjDocker::Commands::ConfigureGet.new(['registry_url'])
    }.not_to raise_error
    # rubocop:enable all
    expect { key_val = confget.start }.not_to raise_error
    expect(key_val).to eq 'docker'
  end
end
