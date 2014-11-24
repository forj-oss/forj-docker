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
if ENV['RAKE_DEBUG'] == 'true'
  require 'debugger'
  debugger
end
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'yaml'

# disable the puppet build task
Rake::Task["build"].clear

# load relative libs
$LOAD_PATH << File.dirname(__FILE__)
require 'lib/tasks/forj-docker'


#
# puppet lint
#
PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send('disable_class_parameter_defaults')
#PuppetLint.configuration.send('disable_documentation')
#PuppetLint.configuration.send('disable_single_quote_string_with_variables')
PuppetLint.configuration.ignore_paths = ["git/**","spec/fixtures/**","spec/**/*.rb","spec/**/*.pp", "pkg/**/*.pp"]



#
# beaker testing
#  use BEAKER_destroy=no env to stop from destroying containers
# connect with ssh root@localhost -p <the port of the container>
# password root
#desc "do beaker based spec testing"
#task :acceptance,:platform do |t, args|
#  args.acceptance(:platform => :default)
#  puts "running acceptance test : #{args}"
#  if args.count > 0 && args[0].to_sym != :default
#    ENV['BEAKER_node'] = args[0]
#  end
#  Rake::Task['spec_prep'].invoke
#  Rake::Task['beaker'].invoke
#  Rake::Task['spec_clean'].invoke
#end
