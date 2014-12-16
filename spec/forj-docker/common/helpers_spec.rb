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

# Test Helper module
#
# *Test*
# * test find_files
spec_dir = File.join(File.expand_path(File.dirname(__FILE__)), '..')
$LOAD_PATH << spec_dir
require 'spec_helper'
require 'rubygems'

$LOAD_PATH << File.join(spec_dir, '..', 'lib')
require 'forj-docker/common/log'
require 'forj-docker/common/helpers'

describe 'Helper file operation functions', :default => true do
  before :all do
  end

  it 'gethome_path should get the current users home directory' do
    home_path = gethome_path
    expect { gethome_path }.not_to raise_error
    expect(home_path.length).to be > 0
  end

  it 'create_directory should make a folder' do
    if dir_exists?('spec/fixtures/test/helper')
      command('rm -rf spec/fixtures/test/helper')
    end
    expect { create_directory 'spec/fixtures/test/helper' }.not_to raise_error
  end

  it 'dir_exists? check' do
    expect(command('mkdir -p spec/fixtures/dir_exist').exit_status).to eq 0
    expect { dir_exists? 'spec/fixtures/dir_exist' }.not_to raise_error
    expect(dir_exists? 'spec/fixtures/dir_exist').to be true
    expect(dir_exists? 'spec/fixtures/dir_not_exist').to be false
  end

  it 'validate_directory path not exist' do
    error_raised = false
    begin
      validate_directory 'spec/fixtures/dir_not_exist'
    rescue
      error_raised = true
    end
    expect(error_raised).to be true
  end

  it 'validate_file_andwarn fspec not exist' do
    command('touch spec/fixtures/file').exit_status
    expect { validate_nofile_andwarn 'spec/fixtures/file' }
      .not_to raise_error
  end

  it 'validate_nofile_andwarn no file exist and warn' do
    expect { validate_nofile_andwarn 'spec/fixtures/nofile' }
      .not_to raise_error
  end

  it 'ensure_dir_exists creates a directory' do
    command('rm -rf spec/fixtures/dir_exists').exit_status
    expect(command('test -d spec/fixtures/dir_exists').exit_status).not_to eq 0
    expect { ensure_dir_exists 'spec/fixtures/dir_exists' }.not_to raise_error
    expect(command('test -d spec/fixtures/dir_exists').exit_status).to eq 0
  end

  it 'create_file with specific contents' do
    error_raised = false
    begin
      create_file 'test file contents', 'spec/fixtures/create_file'
    rescue
      error_raised = true
    end
    expect(error_raised).to be false
    expect(command('cat spec/fixtures/create_file').stdout)
      .to eq('test file contents')
  end

  it 'remove_file from fixtures' do
    expect(command('touch spec/fixtures/remote_file').exit_status).to eq 0
    expect(File.exist? 'spec/fixtures/remote_file').to be true
    error_raised = false
    begin
      remove_file 'spec/fixtures/remote_file'
    rescue
      error_raised = true
    end
    expect(error_raised).to be false
    expect(File.exist? 'spec/fixtures/remote_file').to be false
  end

  it 'find_files in a folder' do
    expect(command('mkdir -p spec/fixtures/folder1/sub1').exit_status).to eq 0
    expect(command('mkdir -p spec/fixtures/folder1/sub2').exit_status).to eq 0
    expect(command('touch spec/fixtures/folder1/sub2/Dockerfile1').exit_status)
      .to eq 0
    expect(command('touch spec/fixtures/folder1/sub2/Dockerfile2').exit_status)
      .to eq 0
    expect(command('touch spec/fixtures/folder1/sub1/Dockerfile1').exit_status)
      .to eq 0
    expect { find_files(/Dockerfile.*/, 'spec/fixtures/folder1') }
      .not_to raise_error
    expect(find_files(/Dockerfile.*/, 'spec/fixtures/folder1').length).to eq 3
  end
end
