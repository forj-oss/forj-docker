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
# start vagrant file
#
namespace :vagrant do
  desc 'vagrant::provision build steps'
  task :provision, [:action] do | _t, args|
    args = { :action => :dev }.merge(args)
    puts "running vagrant action ==> #{args}"
    case args[:action].to_sym
    when :help
      puts "These are the supported options for vagrant task:
      rake 'vagrant[clean]':   clean this machine.
      rake 'vagrant[dev]':     create a dev environment.
      rake 'vagrant[build]':   build any docker image in the vm.
      rake 'vagrant[connect]': connect to the vagrant machine."
    when :clean
      puts 'Destroy this vagrant environment'
      sh('vagrant destroy -f')
    when :dev
      Rake::Task['check'].execute
      puts 'Vagrant setup dev environment and connect'
      sh('vagrant up --no-provision')
      sh('vagrant provision')
      sh('vagrant ssh')
    when :build
      puts 'Build all the docker images in vagrant'
      sh('vagrant up')
      sh("vagrant ssh \\
          --command 'bash -c \\
          \"export DOCKER_WORKAREA=/vagrant/docker;\\
          /vagrant/bin/scripts/docker_prepare.sh\"'")
    when :connect
      puts 'Vagrant perform connection to box'
      sh('vagrant ssh')
    else
      puts 'You gave me #{args[:action]} - I have no idea what to do with that.'
    end
  end

  #
  # we should verify that we can do things with vagrant
  #
  desc 'basic check for docker execution in vagrant'
  task :check, [:ignore] do  | _t, args |
    args = (!args.nil?) ? { :ignore => false }.merge(args) :
                          { :ignore => false }
    if args[:ignore] != true
      puts 'Verifying vagrant...'
      RSpec::Core::RakeTask.new(:check_spec) do |ct|
        ct.pattern = File.join(FORJ_DOCKER_SPEC,
                               '{check_vagrant}',
                               '**',
                               '*_spec.rb')
        ct.rspec_opts = ['--color']
      end
      Rake::Task[:check_spec].invoke
    else
      puts 'Ignoring checks'
    end
  end

  #
  # execute runit on each docker container we know about
  #
  desc 'runit for each docker workarea'
  task :runit do
    puts 'does nothing atm'
  end

  #
  # build the registry container on vagrant
  #
  desc 'build the docker registry container'
  task :registry_build do
    puts 'building a registry container build'
    sh('vagrant up')
    sh("vagrant ssh \\
        --command 'bash -c \\
        \"export DOCKER_WORKAREA=/vagrant/docker-registry;\\
        /vagrant/bin/scripts/docker_reg_setup.sh\"'")
  end

  #
  # start the registry container on vagrant
  #
  desc 'start and run the docker registry container'
  task :registry do
    puts 'starting the registry container'
    sh('vagrant up')
    sh("vagrant ssh \\
        --command 'bash -c \\
        \"export DOCKER_WORKAREA=/vagrant/docker-registry;\\
        /vagrant/bin/scripts/docker_reg_up.sh\"'")
  end

  desc 'manage containers publishing, for help run task "containers[help]"'
  task :containers, [:action] do | _t, args|
    args = { :action => :help }.merge(args)
    puts "running containers action ==> #{args}"
    case args[:action].to_sym
    when :help
      puts "These actions can be performed on docker work areas for containers:
      rake 'containers[pull]':   pull all containers defined by work area.
      rake 'containers[push]':   push all containers defined by work area.
      rake 'containers[list]':   list all containers in a defined work area.
      rake 'containers[help]':   this help text."
    when :pull
      puts 'TODO: needs implementation'
      # cli/commands/containers
      # also available as :
      # forj-docker containers pull
    when :push
      puts 'TODO: needs implementation'
      # TODO: this will be implmented with forj-docker commands api
      # cli/commands/containers
      # forj-docker containers push
    when :list
      puts 'TODO: needs implementation'
      require 'forj-docker/cli/commands/containers_list'
    else
      puts 'You gave me #{args[:action]} - I have no idea what to do with that.'
      puts 'Check help with containers[help]'
    end
  end
end
