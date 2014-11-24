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
require 'spec_helper_check'
require 'rubygems'

describe 'vagrant binary', :check => true do
  sh = <<-EOS
    which vagrant
  EOS
  subject { command(sh) }

  it 'should exist' do
    expect(subject.return_stdout?(/vagrant/)).to be_truthy
  end
end

describe service('virtualbox'), :check => true do
  it { should be_enabled   }
  it { should be_running   }
end
