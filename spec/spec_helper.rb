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
require 'serverspec'
set :backend, :exec

#
# configure rspec
#
RSpec.configure do |c|
  c.formatter = :documentation
  c.filter_run :default => true
  c.before(:all, &:setup_spec_helper)
  c.after(:all,  &:cleanup_spec_helper)
end

public

def setup_spec_helper
  #
  # make sure fixtures folder exist
  #
  FileUtils.mkdir_p('spec/fixtures') unless File.exist?('spec/fixtures')

  #
  # make sure we're using lorj
  spec_dir = File.expand_path(File.dirname(__FILE__))
  $LOAD_PATH << File.join(spec_dir, '..', 'lib')
  require 'forj-docker/common/helpers'
  include Helpers
  require 'lorj'
  PrcLib.data_path  = File.expand_path(File.join('spec',
                                                 'fixtures',
                                                 '.config',
                                                 'forj-docker'))
  PrcLib.app_name = 'forj-docker-undertest'
  PrcLib.level = Logger::FATAL
  # PrcLib.log_file

  $RT_GEM_HOME = File.expand_path(File.join(__FILE__,
                                            '..',  # spec
                                            '..')) # /
  $RT_GEM_BIN = File.join($RT_GEM_HOME, 'bin')
  $RT_VERSION_SPEC = File.join($RT_GEM_HOME, 'VERSION')
  PrcLib.app_defaults = File.join($RT_GEM_HOME, 'forj-docker')
end

# check if we show more messages to debug failed specs.
#
def spec_debug
  return (ENV['SPEC_DEBUG'] == '1') if !ENV['SPEC_DEBUG'].nil? ||
                                       ENV['SPEC_DEBUG'] != ''
  false
end

def cleanup_spec_helper
  puts 'all done'
end
