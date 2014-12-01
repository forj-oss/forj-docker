#Introduction
We are experimenting with docker.  This project will use maestro and redstone to setup docker images locally that can be used to start/stop docker images for each node.  Currently a forj blueprint might requires 4 nodes.  With docker we will use a container to represent these nodes.  Later we might move this concept of nodes to be more container specific to include smaller units of work or process ownership in the blueprint.  For example, a disk/network/db container that interacts with all other application service containers to produce the concept of a node.  

This project offers us a way to deliver as a gem a new feature to a host operating system that can be incorporated into the existing blueprint layout.  From the blueprint layout you can then in theory execute container based commands designed to work with the blueprint.   Further we can create a provisioner for the forj cli that also interacts with these commands.

Ideally, here are some of the commands we would have:

##For building and developing images:

  ```rake dev```   - stand up an environment with docker (we'll use vagrant or bare systems). This installs docker as well.

  ```rake build``` - for the provided Rakefile, look for the docker folder to assign a DOCKER_WORKAREA and build all dockerfiles found in this subfolders of this workarea.  Images are stored locally in the host machine.

## For managing docker images

  ```rake registry``` - create a system that will host published images.  

  ```rake pull``` - for the given Rakefile, pull the conatiner images to the host system for the given docker workarea.

  ```rake push``` - in conjunction with a security file managed by ```rake configure```,and as provided by the Rakefile, publish the docker workarea containers that have been built.  If the containers, don't exist, error and ask for a ```rake build``` execution.

##For running a cluster of nodes/containers on a given host
  ```rake runit``` - for the provided Rakefile, find the blueprint config and run the containers for this image.  If the containers are not found locally, we will atempt to pull them.


## Node descriptions
* maestro - provies a ui that allows you to navigate to each node.
* review  - provides an scm service for git
* ci      - provides a jenkins build service
* util    - provides for utility services like paste and logstash

##Status for this work is experimental.

* setup a vm for docker images
  vagrant up
* prepare all docker images in the docker folder
   vagrant ssh
   docker_prepare.sh
* Start a review server
   vagrant ssh
   dockerup -a review -t forj/redstone:review -n review.42.localhost

 NOTE: registry, pull, push, and runit task need to be developed.

## Building forj-docker gem
* build the project gem file
```shell
 rake clean
 rake build
```
* publish the project
```shell
 rake release
```

## Developer getting started
* Install rake tools
```shell
  sudo -E gem1.9.1 install bundler --no-rdoc --no-ri
  ruby1.9.1 -S bundle install --gemfile Gemfile
```
* Install vagrant for your OS otherwise run bare with the command: ```rake 'configure[bare]'```
* Start the dev vm with commad:
```shell
  rake dev
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
* we need a docker_runit.sh script that will start all our containers.
  This script might need to be multiple steps to implement the instaler
  and configuration of the software managing all the containers on the host.
  Ideally it should be smart enough to just bring in blueprint config
  and initiate the startup.
* we need to implement the version tagging on docker_prepare.sh
  I would like container images we build to have version numbers.
* we need a docker_install_registry.sh script to install a private registry.
  garether plugin has a nice way to setup and deploy a private registry.
  There should be a build target and script that can use this plugin to
  do that for us.
* we need to start the ruby library to integrate forj-cli, and it's rake specs.
  The ruby library should implement a pattern that allows us to simply
  configure a blueprint workarea and allow it to define the DOCKER_WORKAREA.
  The DOCKER_WORKAREA should be what is used to help identify the docker files
  that will be managed on a host.  Having this as a ruby gem will make it
  easier for us to integrate and use on several host systems.
* we need test cases for each of the top level scripts.
  Lets start with a check target that verifies docker is installed and the right version.
  For vagrant systems verify vagrant and virtual box are installed.
* thoughts about giving dockerup the ability to transfer meta.js to docker image using --env settings??
  One of the main functions being offered by cloud-init was the ability to
  communicate metadata configured by forj cli.   We'll need the same to help
  our docker containers define host specific configuration that the docker images
  will need to communicate with each other.  We need to investigate this area.
* implement docker_clean.sh
  rake clean should call docker_clean.sh so that all the docker images configured
  by DOCKER_WORKAREA are removed from the host machine.

## DONE
* we need to extract the docker_install.sh script from the Vagrantfile and call it as a provisioner script.
  rake build and dev targets for vagrant provisioner will now do this automatically.
  On bare systems you can simply run src/docker_install.sh on the system you want to dockerize.
  We use garethr plugin for the heavy lifting.

#License
forj-docker is licensed under the Apache License, Version 2.0.  See LICENSE for full license text.
