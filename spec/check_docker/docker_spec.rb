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
require 'spec_helper'
require 'rubygems'
describe 'check docker requirements', :default => true do
  it 'docker should be version 1.3.1 or higher' do
    docker_version = sh("docker --version|awk -F, '{print $1}'|awk '{print $3}'")
    expect(Gem::Version.new(docker_version) > Gem::Version.new('1.3.1')).to be_true
  end
end
