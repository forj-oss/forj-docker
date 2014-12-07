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
# start bare file
#
require 'rake/clean'
namespace :bare do
  desc 'bare::provision build steps'
  task :provision, [:action] do | _t, args |
    args = { :action => :dev }.merge(args)
    puts "running bare action ==> #{args}"
    case args[:action].to_sym
    when :help
      puts "These are the supported options for vagrant task:
      rake 'bare[clean]'  : perform any local clean operations.
      rake 'bare[dev]'    : no-op.
      rake 'bare[build]'  : prepare the docker containers found.
      rake 'bare[connect]': no-op."
    when :clean
      puts 'Cleanup for docker bulid steps'
      sh("find #{DOCKER_WORKAREA} -name 'Dockerfile' -type l|xargs -i rm -f {}")
      sh("find #{DOCKER_WORKAREA} -name 'build' -type d|xargs -i rm -fr {}")
      CLEAN.include('git/*', 'src/git/*')
    when :dev
      sh("bash #{FORJ_DOCKER_BIN}/scripts/docker_install.sh")
    when :build
      puts 'Build all the docker images locally'
      ENV['DOCKER_WORKAREA'] = DOCKER_WORKAREA
      sh("bash #{FORJ_DOCKER_BIN}/scripts/docker_prepare.sh")
    when :connect
      # mainly used for development so later we might enhance this to work
      # with the gem as well.
      # connect to this projects default box located in the docker folder
      sh("bash #{FORJ_DOCKER_BIN}/scripts/docker_up.sh \
         -t 'forj/redstone:review' -a dev -n devcontainer.localhost")
    else
      puts "You gave me #{args[:action]} - I have no idea what to do with that."
    end
  end

  #
  # we should verify that we can do things with our local bare system
  #
  desc 'basic check for local execution of docker'
  task :check, [:ignore] do | _t, args|
    args = (!args.nil?) ? { :ignore => false }.merge(args) :
                          { :ignore => false }
    if args[:ignore] != true
      puts 'Verifying bare...'
      RSpec::Core::RakeTask.new(:check_spec) do |ct|
        ct.pattern = File.join(FORJ_DOCKER_SPEC,
                               '{check_docker}',
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
end
