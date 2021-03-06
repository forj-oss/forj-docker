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
require 'spec_helper_check'
require 'rubygems'

SUPPORTED_OSFAMS = %w(redhat debian centos ubuntu)

describe 'check for vagrant binary', :check => true do
  sh = <<-EOS
    which vagrant
  EOS
  subject { command(sh) }
  its(:stdout) { should match(/vagrant/) }
  its(:exit_status) { should eq 0 }
end

describe 'check for virtualbox binary', :check => true do
  sh = <<-EOS
    which virtualbox
  EOS
  subject { command(sh) }
  its(:stdout) { should match(/virtualbox/) }
  its(:exit_status) { should eq 0 }
end

describe service('virtualbox'),
         :if => (SUPPORTED_OSFAMS.include?(os[:family].downcase) &&
                 !package('virtualbox').version.nil?),
         :check => true do
  it { should be_enabled   }
end

describe service('vboxdrv'),
         :if => (SUPPORTED_OSFAMS.include?(os[:family].downcase) &&
                 !package('virtualbox-4.\*').version.nil?),
         :check => true do
  it { should be_enabled   }
end
