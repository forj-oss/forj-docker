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

#
# start vagrant file
#
desc "vagrant build step"
task :vagrant,[:action] do |t, args|
    args = {:action => :dev}.merge(args)
    puts "running vagrant action ==> #{args}"
    case args[:action].to_sym
    when :help
      puts "These are the supported options for vagrant task:
      rake 'vagrant[clean]':   clean this machine.
      rake 'vagrant[dev]':     create a dev environment.
      rake 'vagrant[build]':   build any docker image in the vm.
      rake 'vagrant[connect]': connect to the vagrant machine."
    when :clean
      puts "Destroy this vagrant environment"
      sh("vagrant destroy -f")
    when :dev
      puts "Vagrant setup dev environment and connect"
      sh("vagrant up --no-provision")
      sh("vagrant provision")
      sh("vagrant ssh")
    when :build
      puts "Build all the docker images in vagrant"
      sh("vagrant up")
      sh("vagrant ssh --command 'bash -c \"/vagrant/docker_prepare.sh\"'")
    when :connect
      puts "Vagrant perform connection to box"
      sh("vagrant ssh")
    else
      puts "You gave me #{args[:action]} -- I have no idea what to do with that."
    end
end

#
# default the clean task to vagrant clean
#
desc "run vagrant[clean]"
task :clean do
  Rake::Task['vagrant'].invoke('clean')
end

#
# default the dev | development task to vagrant dev
#
desc "run vagrant[dev]"
task :dev do
  Rake::Task['vagrant'].invoke('dev')
end
desc "run vagrant[dev]"
task :development do
  Rake::Task['vagrant'].invoke('dev')
end
#
# connect to the provisioner
#
desc "run vagrant[connect]"
task :connect do
  Rake::Task['vagrant'].invoke('connect')
end
#
# build with the provisioner
#
desc "run vagrant[build]"
task :build do
  Rake::Task['vagrant'].invoke('build')
end

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
