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
VERSION_FILE = File.join(File.expand_path(File.join(__FILE__,"..")),"VERSION")
GEM_VERSION=(File.exist?(VERSION_FILE)) ? `cat "#{VERSION_FILE}"` : "0.0.1"
GEM_NAME=`cat *.gemspec|grep 's.name' | awk -F= '{print $2}'|sed -e 's/^\s"//' -e 's/"$//'`.gsub("\n","")

if ENV['RAKE_DEBUG'] == 'true'
  require 'debugger'
  debugger
end
require 'rake/clean'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'yaml'

# disable the puppet build task
Rake::Task["build"].clear

# load relative libs
if "#{ENV['FORJ_TEST']}" == "1"
  $LOAD_PATH << File.join(File.dirname(__FILE__),"lib")
  require 'forj-docker/tasks/forj-docker'
else
  puts "Skipping any forj-docker task..."
  puts "to enable in project, export FORJ_TEST=1"
end

#
# things to clean
#
CLEAN.include("#{GEM_NAME}*.gem")
CLOBBER.include('*.tmp', 'build/*')

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

desc "build a gem for #{GEM_NAME}-#{GEM_VERSION}"
task :build do
  system "gem build #{GEM_NAME}.gemspec"
end

desc "release a gem for #{GEM_NAME}-#{GEM_VERSION}"
task :release => :build do
  system "gem push #{GEM_NAME}-#{GEM_VERSION}"
end

desc "install gem from build for #{GEM_NAME}-#{GEM_VERSION}"
task :install => [:clean, :build] do
  system "gem install #{GEM_NAME}-#{GEM_VERSION}.gem"
end
