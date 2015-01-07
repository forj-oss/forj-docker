#Introduction
We are experimenting with docker.  This project will use maestro and redstone to setup docker images locally that can be used to start/stop docker images for each node.  Currently a forj blueprint might requires 4 nodes.  With docker we will use a container to represent these nodes.  Later we might move this concept of nodes to be more container specific to include smaller units of work or process ownership in the blueprint.  For example, a disk/network/db container that interacts with all other application service containers to produce the concept of a node.  

This project offers us a way to deliver as a gem a new feature to a host operating system that can be incorporated into the existing blueprint layout.  From the blueprint layout you can then in theory execute container based commands designed to work with the blueprint.   Further we can create a provisioner for the forj cli that also interacts with these commands.

The project helps us consolidate and integrate other opensource projects that are supporting docker in order to have a full end-to-end solution for building and operating docker based eco systems of applications.

## Concepts and Features
* `docker work area` is set of folders that contain Dockerfiles*.  These dockerfile will have some metadata stored as comments in the header that can be used for building, publishing and running docker containers.  We will likely update this as docker orchestration matures or we adopt another orchestrator (like kuberneties).
* The docker work area can contain docker files that have an `erb` extension.  Key value pairs can be defined with the forj-docker cli for Dockerfile transformation.
* The forj-docker CLI can be used to initialize and setup a docker work area for an existing blueprint or empty blueprint folder structure. All docker files will live under a folder named `docker`.
* When mapping blueprint files, we will use 1 container for each node described in a blueprint.

## Rake commands for building and developing docker images:

  ```rake dev```   - stand up an environment with docker (we'll use vagrant or bare systems). This installs docker as well.

  ```rake build``` - for the provided Rakefile, look for the docker folder to assign a DOCKER_WORKAREA and build all dockerfiles found in this subfolders of this workarea.  Images are stored locally in the host machine.

## Rake commands for managing docker images

  ```rake registry``` - create a system that will host published images.  

  ```rake pull``` - for the given Rakefile, pull the conatiner images to the host system for the given docker workarea.

  ```rake push``` - in conjunction with a security file managed by ```rake configure```,and as provided by the Rakefile, publish the docker workarea containers that have been built.  If the containers, don't exist, error and ask for a ```rake build``` execution.

## Rake commands for operating docker images in a docker work area
  ```rake runit``` - for the provided Rakefile, find the blueprint config and run the containers for this image.  If the containers are not found locally, we will atempt to pull them.

## Installation
  Want to use forj-docker to start your own blueprint for docker?  No problem, lets do it.
  * Install ruby 1.9 for your OS.  Currently we're targeting support for execution within docker, vagrant, or bare using ubuntu 14.04.
```shell
  sudo apt-get -y update
  sudo apt-get install ruby1.9.1            \
      ruby1.9.1-dev        \
      rubygems1.9.1        \
      build-essential      \
      libopenssl-ruby1.9.1 \
      libssl-dev           \
      zlib1g-dev           \
      libxml2-dev          \
      libxslt-dev          \
      ncurses-dev          \
      git -y
```
  * Install forj-docker gem.
```shell
  sudo -i ruby1.9.1 -S gem install forj-docker
```

## Usage
  * Create a root folder for your blueprint project
```shell
  mkdir -p ~/forj/myblueprint
  cd ~/forj/myblueprint
  forj-docker init
```
  * Get help for the rake commands you can run:
```shell
  rake -T

  and

  forj-docker help
```
  * build the docker images in your docker work area:
```shell
  rake build
```
  * Test your images with dockerup, it remembers your sessions!
```shell
   rake connect

   or

   dockerup -a review -t forj/redstone:review -n review.42.localhost
 ```

## Developer getting started
If you plan to build this gem or install it within a docker or vagrant container, you'll need some ruby build tools.
We'll use bundler and rake for ruby.

### Develop with ruby 1.9+ on ubuntu
We highly recommend developing on ubuntu using an editor like atom or vi.
Install ruby 1.9 packages to build and develop gems.

### Install rake tools
* Install with default ruby
```shell
  sudo -E gem install bundler --no-rdoc --no-ri
  ruby -S bundle install --gemfile Gemfile
```
* Install with ruby1.9
```shell
  sudo -E gem1.9.1 install bundler --no-rdoc --no-ri
  ruby1.9.1 -S bundle install --gemfile Gemfile
```

### forj-docker run modes.
When developing in forj-docker project, the root Rakefile supports different rake task run modes.   These are designed to help speed up development and test.
* **forj-docker gem build mode**:  By default this is the configured run mode, and will only build the forj-docker gem.  No additional docker rake task will be availalbe.  Setup with command:
```shell
  rake runbuild
```
* **running in container mode**.  This mode will make available additional task that can be used to do things such as spawn a working docker host system using vagrant for development. If you
are doing rake task work, this is the proper run mode.
Setup with command:
```shell
  rake rundev
```

### Configure docker host environment.
Currently we allow for docker host environments to be run on bare system (locally), or inside a vagrant virtualbox environment.   This can be configured after using ```rake rundev``` or after installing a Rakefile with the forj-docker task (```forj-docker init```).
* Run docker on a bare system:
```shell
  rake 'configure[bare]'
```
* Run docker inisde a vagrant virtualbox machine (ie; for windows):
```shell
  rake 'configure[vagrant]'
```

The default run mode will be bare.

### Start the dev vm with command:
You can develop or setup an environment to run docker with forj-docker rake task.  We will leverage puppet to setup and install docker on the local host.

```shell
  rake rundev
  rake dev
```

## Building forj-docker gem
* How to build the gem for this project.
```shell
 rake runbuild
 rake clean
 rake build
```

* installing the gem from local .gem file your developing
```shell
 rake install
 # test it
 forj-docker
```

* publish the project (TODO)
```shell
 rake release
```

* Build the docker images in docker/**
```shell
  rake build
```
* looking at a docker image after a build step to interrogate it.
```shell
  # in this example we connect to the redstone blueprint with the review tag.
  rake connect
  dockerup -t forj/redstone:review -c
```

* example dockerup without a proxy configured
```shell
  rake connect
  dockerup -t forj/redstone:review --opts "--env PROXY=" -n "review.42.localhost" -c
  # observice the fqdn
  facter fqdn
```

* experiment 1: can we stand up the review instance without maestro or a puppetmaster?
```shell
  rake connect
  dockerup -t forj/redstone:review -n "review.42.localhost" -c
  # TODO: test for puppet, facter, and hiera
  # note PUPPET_MODULES is already setup by Docker image
  # lets setup the hiera data.
```  

 TODO investigate long execution times, factors??
```shell
    puppet apply --modulepath=$PUPPET_MODULES \
                 --debug --verbose  \
                 -e "
 include pip::python2
 class {'hiera': data_class => 'hiera::data' } ->
 class {'runtime_project::hiera_setup':}
 "
```

## Using dockerup alias
The ```dockerup``` alias is a bash shell alias used on host machines for making it easier to interact with docker and the images we'll create with blueprints.

To get started either use ```rake dev``` where the dockerup alias is automatically setup, or setup the alias with the command ```alias dockerup=./docker_up.sh```

To get help run: ```dockerup -h```

## TODO
* forj-docker should build the docker workarea based
  on the blueprint layout, and pre-pend the require task for an existing Rakefile.
* forj-docker docker workarea should support a docker file configuration where a scripts/bash folder is supported.  Each script in the scripts/bash folder will be executed in sequence, as named.
* forj-docker/lib folder needs complete spec testing.
* registry, pull, push, and runit task need to be developed.
* we need a docker_runit.sh script that will start all our containers.
  This script might need to be multiple steps to implement the instaler
  and configuration of the software managing all the containers on the host.
  Ideally it should be smart enough to just bring in blueprint config
  and initiate the startup.
* we need to implement the version tagging on docker_prepare.sh
  I would like container images we build to have version numbers.
* thoughts about giving dockerup the ability to transfer meta.js to docker image using --env settings??
  One of the main functions being offered by cloud-init was the ability to
  communicate metadata configured by forj cli.   We'll need the same to help
  our docker containers define host specific configuration that the docker images
  will need to communicate with each other.  We need to investigate this area.
* implement docker_clean.sh
  rake clean should call docker_clean.sh so that all the docker images configured
  by DOCKER_WORKAREA are removed from the host machine.
* publish the forj-docker gem as a part for review.forj.io process for publishing step.
* create a release task for forj-docker, and add that to review.forj.io with release notes changes.

## DONE
* forj-docker is now a gem, and forj-docker init is the first command to install rake task for custom projects.
* use rake check to verify your environment
* we need to extract the docker_install.sh script from the Vagrantfile and call it as a provisioner script.
  rake build and dev targets for vagrant provisioner will now do this automatically.
  On bare systems you can simply run src/docker_install.sh on the system you want to dockerize.
  We use garethr plugin for the heavy lifting.
* we need a docker_install_registry.sh script to install a private registry.
  garether plugin has a nice way to setup and deploy a private registry.
  There should be a build target and script that can use this plugin to
  do that for us.
#License
forj-docker is licensed under the Apache License, Version 2.0.  See LICENSE for full license text.
