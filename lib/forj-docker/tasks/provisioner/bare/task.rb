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
  task :provision, [:action] do |_t, args|
    args = { :action => :dev }.merge(args)
    PrcLib.message "running bare action ==> #{args}"
    case args[:action].to_sym
    when :help
      help_message = <<-MESSAGE
      These are the supported options for vagrant task:

        rake 'bare[clean]'  : perform any local clean operations.
        rake 'bare[dev]'    : no-op.
        rake 'bare[build]'  : prepare the docker containers found.
        rake 'bare[connect]': no-op.
      MESSAGE
      PrcLib.message help_message
    when :clean
      PrcLib.message 'Cleanup for docker bulid steps'
      sh("find #{DOCKER_WORKAREA} -name 'Dockerfile' -type l|xargs -i rm -f {}")
      sh("find #{DOCKER_WORKAREA} -name 'build' -type d|xargs -i rm -fr {}")
      CLEAN.include('git/*', 'src/git/*')
    when :dev
      sh("bash #{FORJ_DOCKER_BIN}/scripts/docker_install.sh")
    when :build
      PrcLib.message 'Build all the docker images locally'
      ENV['DOCKER_WORKAREA'] = DOCKER_WORKAREA
      sh("bash #{FORJ_DOCKER_BIN}/scripts/docker_prepare.sh")
    when :connect
      # mainly used for development so later we might enhance this to work
      # with the gem as well.
      # connect to this projects default box located in the docker folder
      sh("bash #{FORJ_DOCKER_BIN}/scripts/docker_up.sh \
         -t 'forj/redstone:review' -a dev -n devcontainer.localhost")
    else
      error_message = <<-MESSAGE
      You gave me #{args[:action]} - I have no idea what to do with that.
      MESSAGE
      PrcLib.error error_message
    end
  end

  #
  # we should verify that we can do things with our local bare system
  #
  desc 'basic check for local execution of docker'
  task :check, [:ignore] do |_t, args|
    args = { :ignore => false }
    args = { :ignore => false }.merge(args) unless args.nil?
    if args[:ignore] != true
      PrcLib.message 'Verifying bare...'
      RSpec::Core::RakeTask.new(:check_spec) do |ct|
        ct.pattern = File.join(FORJ_DOCKER_SPEC,
                               '{check_docker}',
                               '**',
                               '*_spec.rb')
        ct.rspec_opts = ['--color']
      end
      Rake::Task[:check_spec].invoke
    else
      PrcLib.warning 'Ignoring checks'
    end
  end

  #
  # execute runit on each docker container we know about
  #
  desc 'runit for each docker workarea'
  task :runit do
    PrcLib.warning 'does nothing atm'
  end

  #
  # implement this using a default docker container.
  # The container config should lib in config/default/registry.
  # name it forj/docker:registry
  # should expose a data folder with mount points at /opt/docker/data
  # for Docker registry details see your cloned docker-registry/Dockerfile
  #
  desc 'build(local) the docker registry container'
  task :registry_build do
    sh("bash #{FORJ_DOCKER_BIN}/scripts/docker_reg_setup.sh")
  end

  #
  # implements running a docker registry server
  #
  desc 'start and run the docker registry container (local)'
  task :registry do
    sh("bash #{FORJ_DOCKER_BIN}/scripts/docker_reg_up.sh")
  end

  desc 'manage containers publishing, for help run task "containers[help]"'
  task :containers, [:action] do |_t, args|
    args = { :action => :help }.merge(args)
    PrcLib.message "running containers action ==> #{args}"

    case args[:action].to_sym
    when :help
      help_message = <<-MESSAGE
      These actions can be performed on docker work areas for containers:

      rake 'containers[pull]':   pull all containers defined by work area.
      rake 'containers[push]':   push all containers defined by work area.
      rake 'containers[list]':   list all containers in a defined work area.
      rake 'containers[help]':   this help text.
      MESSAGE
      PrcLib.message help_message
    when :pull
      PrcLib.message 'TODO: needs implementation'
      # cli/commands/containers
      # also available as :
      # forj-docker containers pull
    when :push
      PrcLib.message 'TODO: needs implementation'
      # TODO: this will be implmented with forj-docker commands api
      # cli/commands/containers
      # forj-docker containers push
    when :list
      require 'forj-docker/cli/commands/containers_list'
      debug_opts = { :debug   => FORJ_DOCKER_DEBUG,
                     :verbose => FORJ_DOCKER_DEBUG,
                     :quiet   => !FORJ_DOCKER_DEBUG }
      # params containers alternate docker-work area
      # options containers debug and verbose flags
      options = { :docker_workarea => DOCKER_WORKAREA,
                  :quiet => true }.merge debug_opts
      docker_data = ForjDocker::Commands::ContainersList.new([], options).start
      docker_data[:containers].each do |d|
        PrcLib.message d[:repo_name]
      end
    else
      error_message = <<-MESSAGE
      You gave me #{args[:action]} - I have no idea what to do with that.
         Check help with containers[help]
      MESSAGE
      PrcLib.error error_message
    end
  end
end
