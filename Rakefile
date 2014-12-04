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
require 'yaml'
require 'rake/clean'
begin
  require 'puppetlabs_spec_helper/rake_tasks'
  require 'puppet-lint/tasks/puppet-lint'
  # disable the puppet build task
  Rake::Task["build"].clear
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
rescue LoadError
  puts "missing pupptlabs-spec and puppet-lint, skipping..."
end


# load relative libs
$LOAD_PATH << File.join(File.dirname(__FILE__))
begin
  require 'lib/forj-docker/tasks/config.rb'
  do_loaddev = get_config(:forj_dev,  {:forj_dev => false})
rescue
  do_loaddev = false
end
if "#{ENV['FORJ_DEV']}" == "1" || do_loaddev
  require 'lib/forj-docker/tasks/forj-docker'
else
  puts "Skipping any forj-docker task..."
  puts "  to enable in project, export FORJ_DEV=1 or execute 'rake rundev'"
end

#
# things to clean
#
CLEAN.include("#{GEM_NAME}*.gem")
CLOBBER.include('*.tmp', 'build/*')


desc "build a gem for #{GEM_NAME}-#{GEM_VERSION}"
task :build do
  system "gem build #{GEM_NAME}.gemspec"
end

desc "release a gem for #{GEM_NAME}-#{GEM_VERSION}"
task :release => :build do
  system "gem push #{GEM_NAME}-#{GEM_VERSION}"
end

desc "perform a local install of gem from build for #{GEM_NAME}-#{GEM_VERSION}"
task :install => [:clean, :build] do
  begin
    system "sudo -i gem install $(pwd)/forj-docker-*.gem --no-rdoc --no-ri"
  rescue
    puts "Failed to install, try it manually: "
    puts "sudo -i gem install $(pwd)/forj-docker-*.gem --no-rdoc --no-ri"
  end
end

desc "setup FORJ_DEV=1 so we can run in dev mode."
task :rundev do
  write_config(:forj_dev, true)
  puts "new task will be loaded, check rake -T"
end

desc "setup FORJ_DEV off so we can just do builds."
task :runbuild do
  write_config(:forj_dev, false)
  puts "disabling dev, only building gems, check rake -T"
end
