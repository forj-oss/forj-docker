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
# Test forj-docker init
#
# *Test*
# * init an empty folder template
# * init a blueprint template
spec_dir = File.join(File.expand_path(File.dirname(__FILE__)), '..', '..')
$LOAD_PATH << spec_dir
require 'rubygems'
require 'fileutils'
require 'spec_helper'
require 'lib/mocks/clispec'
include CliSpec::InitDefaults

$LOAD_PATH << File.join(spec_dir, '..', 'lib')

# test vanilla init
describe 'init an empty folder template', :default => true do
  before :all do
    @work_dir = 'spec/fixtures/init_empty'
    #
    # test the forj-docker init
    #
    @sh = <<-EOS
    set -x -v
    [ ! -d "#{@work_dir}" ] && mkdir -p "#{@work_dir}"
    _cwd=$(pwd)
    FORJ_DOCKER_LIB=$(pwd)/lib
    cd "#{@work_dir}"
    if [ $? -eq 0 ]; then
      ruby1.9.1 -I $FORJ_DOCKER_LIB -e "#{forj_script}" init
      s=$?
    fi
    cd $_cwd
    return $s
    EOS
    puts 'running command :' if spec_debug
    puts @sh if spec_debug

    @command_res = command(@sh)
    # force execution
    FileUtils.rm_rf @work_dir if File.exist?(@work_dir)
    puts "exit => #{@command_res.exit_status}" if spec_debug
    puts "stdout => #{@command_res.stdout}" if spec_debug
    puts "stderr => #{@command_res.stderr}" if spec_debug
    puts 'setup complete' if spec_debug
  end

  #
  # the default should work without errors
  #
  it 'init empty should create docker work_area' do
    expect(@command_res.exit_status).to eq 0
    spec_init_files_empty.each do |init_file|
      puts "check for -> #{init_file}" if spec_debug
      files_setup = Dir.glob("#{@work_dir}/**/*", File::FNM_DOTMATCH)
                    .select { |f| !File.directory? f }
      expect(files_setup).to include init_file
    end
  end
end

# test blueprint init
describe 'init mock blueprint folder', :default => true do
  before :all do
    # setup a mock bluprint
    spec_blueprint_setup
    #
    # test the forj-docker init
    #
    @sh = <<-EOS
    set -x -v
    [ ! -d "#{spec_work_dir}" ] && mkdir -p "#{spec_work_dir}"
    _cwd=$(pwd)
    FORJ_DOCKER_LIB=$(pwd)/lib
    cd "#{spec_work_dir}"
    if [ $? -eq 0 ]; then
      ruby1.9.1 -I $FORJ_DOCKER_LIB -e "#{forj_script}" init
      s=$?
    fi
    cd $_cwd
    return $s
    EOS
    puts 'running command :' if spec_debug
    puts @sh if spec_debug

    @command_res = command(@sh)
    # force execution
    FileUtils.rm_rf spec_work_dir if File.exist?(spec_work_dir)
    puts "exit => #{@command_res.exit_status}" if spec_debug
    puts "stdout => #{@command_res.stdout}" if spec_debug
    puts "stderr => #{@command_res.stderr}" if spec_debug
    puts 'setup complete' if spec_debug
  end

  #
  # the default should work without errors
  # TODO: this still needs more work
  it 'init blueprint should create docker work_area' do
    expect(@command_res.exit_status).to eq 0
    # spec_init_files_empty.each do |init_file|
    #   puts "check for -> #{init_file}" if spec_debug
    #   files_setup = Dir.glob("#{@work_dir}/**/*", File::FNM_DOTMATCH)
    #                 .select { |f| !File.directory? f }
    #   expect(files_setup).to include init_file
    # end
  end
end
