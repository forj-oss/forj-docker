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
  desc "vagrant::provision build steps"
  task :provision,[:action] do |t, args|
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
end
