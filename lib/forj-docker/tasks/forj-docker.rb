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
$LOAD_PATH << File.join(File.dirname(__FILE__),'..')
require 'config'
require 'provisioners'

desc "configure the provisioner for this rake project [bare|vagrant]"
task :configure,[:provisioner] do |t,args|
  args = {:provisioner => get_current_provisioner}.merge(args)
  set_current_provisioner(args[:provisioner])
  puts "configured provisioner ==> #{get_current_provisioner}"
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
#
desc "run dev for: #{PROVISIONER}:provision[dev]"
task :dev => [:check] do
  Rake::Task["#{PROVISIONER}:provision"].invoke('dev')
end
desc "run development for alias for dev"
task :development do
  Rake::Task['dev']
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
task :check do
  Rake::Task["#{PROVISIONER}:check"].invoke
end
