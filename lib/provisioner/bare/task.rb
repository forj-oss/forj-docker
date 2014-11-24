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
  desc "bare::provision build steps"
  task :provision,[:action] do |t, args|
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
  # we should verify that we can do things with our local bare system
  #
  desc "basic check for local execution of docker"
  task :check do
    puts "Verifying bare..."
    Rake::Task["spec"].clear
    RSpec::Core::RakeTask.new(:spec) do |t|
      t.pattern = 'spec/{check_docker}/**/*_spec.rb'
    end
    Rake::Task["spec"].execute
  end
end
