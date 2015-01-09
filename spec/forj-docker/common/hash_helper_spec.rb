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

# Test hash_helper
#
# *Test*
spec_dir = File.join(File.expand_path(File.dirname(__FILE__)), '..')
$LOAD_PATH << spec_dir
require 'spec_helper'
require 'rubygems'

$LOAD_PATH << File.join(spec_dir, '..', 'lib')
require 'forj-docker/common/hash_helper'

describe 'hash_helper symoblize_keys', :default => true do
  hash = nil
  before :all do
    hash = { 'a' => { 'b' => 'c' }, 'd' => 'e', Object.new => 'g' }
  end

  it ' hash should be symbolized' do
    expect { hash = hash.sym_keys }.not_to raise_error
    expect(hash.key? :a).to be true
    expect(hash[:a].key? :b).to be true
    expect(hash.key? :d).to be true
  end
end
