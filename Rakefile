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
# configure provisioners, to give us the option for creating docker
# image on as many host targets as possible, we are enabling the
# normal build task to be possible to execute on vagrant or bare systems.
#
def get_current_provisioner
  temp_dir = File.join(File.dirname(__FILE__),"tmp")
  Dir.mkdir(temp_dir) unless File.exist?(temp_dir)
  config_file = File.join(temp_dir,"config.yaml")
  config = {:provisioner => :vagrant}
  if File.exist? config_file
    config = config.merge(YAML::load_file(config_file))
  else
    File.open(config_file, 'w') {|f| f.write config.to_yaml }
  end
  return config[:provisioner]
end

def set_current_provisioner(prov_target)
  temp_dir = File.join(File.dirname(__FILE__),"tmp")
  Dir.mkdir(temp_dir) unless Dir.exist?(temp_dir)
  config_file = File.join(temp_dir,"config.yaml")
  config = {}
  if File.exist? config_file
    config = config.merge(YAML::load_file(config_file))
  end
  config[:provisioner] = prov_target
  File.open(config_file, 'w') {|f| f.write config.to_yaml }
end
PROVISIONER = get_current_provisioner
DOCKER_WORKAREA = (ENV['DOCKER_WORKAREA'] != '' and ENV['DOCKER_WORKAREA'] != nil) ? ENV['DOCKER_WORKAREA'] : 'docker'

desc "configure the provisioner for this rake project [bare|vagrant]"
task :configure,[:provisioner] do |t,args|
  args = {:provisioner => get_current_provisioner}.merge(args)
  set_current_provisioner(args[:provisioner])
  puts "configured provisioner ==> #{get_current_provisioner}"
end

#
# start vagrant file
#
desc "vagrant build steps"
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
      sh("vagrant ssh --command 'bash -c \"/vagrant/src/docker_prepare.sh\"'")
    when :connect
      puts "Vagrant perform connection to box"
      sh("vagrant ssh")
    else
      puts "You gave me #{args[:action]} -- I have no idea what to do with that."
    end
end

#
# start bare file
#
require 'rake/clean'
desc "bare build steps"
task :bare,[:action] do |t, args|
    args = {:action => :dev}.merge(args)
    puts "running bare action ==> #{args}"
    case args[:action].to_sym
    when :help
      puts "These are the supported options for vagrant task:
      rake 'bare[clean]'  : perform any local clean operations.
      rake 'bare[dev]'    : no-op.
      rake 'bare[build]'  : prepare the docker containers found.
      rake 'bare[connect]': no-op."
    when :clean
      puts "Cleanup for docker bulid steps"
      sh("find #{DOCKER_WORKAREA} -name 'Dockerfile' -type l|xargs -i rm -f {}")
      sh("find #{DOCKER_WORKAREA} -name 'build' -type d|xargs -i rm -fr {}")
      CLEAN.include('git/*', 'src/git/*')
    when :dev
      puts "no-op"
    when :build
      puts "Build all the docker images locally"
      sh("bash ./src/docker_prepare.sh")
    when :connect
      puts "no-op"
    else
      puts "You gave me #{args[:action]} -- I have no idea what to do with that."
    end
end

#

#
# default the clean task to vagrant clean
#
desc "run #{PROVISIONER}[clean]"
task :clean do
  Rake::Task[PROVISIONER].invoke('clean')
end

#
# default the dev | development task to vagrant dev
#
desc "run #{PROVISIONER}[dev]"
task :dev do
  Rake::Task[PROVISIONER].invoke('dev')
end
desc "run PROVISIONER[dev]"
task :development do
  Rake::Task['dev']
end
#
# connect to the provisioner
#
desc "run #{PROVISIONER}[connect]"
task :connect do
  Rake::Task[PROVISIONER].invoke('connect')
end
#
# build with the provisioner
#
desc "run #{PROVISIONER}[build]"
task :build do
  Rake::Task[PROVISIONER].invoke('build')
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
