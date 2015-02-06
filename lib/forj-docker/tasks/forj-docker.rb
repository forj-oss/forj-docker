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

# load relative libs
$LOAD_PATH << File.join(File.dirname(__FILE__))
require 'config'
require 'provisioners'
require 'helper'
require 'lorj'
require 'forj-docker/cli/appinit'

desc 'configure the provisioner for this rake project [bare|vagrant]'
task :configure, [:provisioner] do |_t, args|
  args = { :provisioner => getcurrent_provisioner }.merge(args)
  setcurrent_provisioner(args[:provisioner])
  PrcLib.message "configured provisioner ==> #{getcurrent_provisioner}"
end

#
# default the clean task to vagrant clean
#
desc "run clean for: #{PROVISIONER}:provision[clean]"
task :clean do
  Rake::Task["#{PROVISIONER}:provision"].invoke('clean')
end

#
# default the dev | development task to vagrant dev
# NOTE: we don't do check here because provisioning checks are optional
#
desc "run dev for: #{PROVISIONER}:provision[dev]"
task :dev do
  Rake::Task["#{PROVISIONER}:provision"].invoke('dev')
end

#
# add a couple aliases to feal more natural
#
desc 'run development for alias for dev'
task :development do
  Rake::Task['dev'].invoke
end
desc 'run provision for alias for dev'
task :provision do
  Rake::Task['dev'].invoke
end

#
# connect to the provisioner
#
desc "run connect for: #{PROVISIONER}:provision[connect]"
task :connect do
  Rake::Task["#{PROVISIONER}:provision"].invoke('connect')
end

#
# build with the provisioner
#
desc "run build for: #{PROVISIONER}:provision[build]"
task :build => [:check] do
  Rake::Task["#{PROVISIONER}:provision"].invoke('build')
end

#
# check
#
desc "run checks for: #{PROVISIONER}:check"
task :check, [:ignore] do |_t, args|
  args = { :ignore => false }.merge(args)
  Rake::Task["#{PROVISIONER}:check"].invoke(args[:ignore])
end

#
# runit
#
desc "execute runit scripts for each container: #{PROVISIONER}:runit"
task :runit => [:check] do
  Rake::Task["#{PROVISIONER}:runit"].invoke
end

#
# registry_build
#
desc 'build the docker registry container -' \
     " #{PROVISIONER}:registry_build"
task :registry_build do
  Rake::Task["#{PROVISIONER}:registry_build"].invoke
end

#
# implements running a docker registry server
#
desc 'start and run the docker registry container'
task :registry do
  Rake::Task["#{PROVISIONER}:registry"].invoke
end

desc 'manage docker workarea containers, see "containers[help]"'
task :containers, [:action] do |_t, args|
  require 'config'
  args = { :action => :help }.merge(args)
  PrcLib.message "calling provisioner ==> #{PROVISIONER}"
  Rake::Task["#{PROVISIONER}:containers"].invoke(args[:action])
end
