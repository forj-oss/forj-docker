#Introduction
We are experimenting with vagrant.  This project will use maestro and redstone to setup docker images locally that can be used to start/stop docker images for each node.  Currently redstone requires 4 nodes.  We will use one container for each node.

* maestro - provies a ui that allows you to navigate to each node.
* gerrit  - provides an scm service for git
* ci      - provides a jenkins build service
* util    - provides for utility services like paste and logstash

##Status for this work is experimental.

* setup a vm for docker images
  vagrant up
* prepare all docker images in the docker folder
   vagrant ssh
   docker_prepare.sh
* Start a gerrit server
   vagrant ssh
   dockerup -a gerrit -t forj/redstone:gerrit -n gerrit.42.localhost

## Developer getting started
* Install rake tools
```shell
  sudo -E gem1.9.1 install bundler --no-rdoc --no-ri
  ruby1.9.1 -S bundle install --gemfile Gemfile
```
* Install vagrant for your OS
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
  # in this example we connect to the redstone blueprint with the gerrit tag.
  rake connect
  dockerup -t forj/redstone:gerrit -c
```

* example dockerup without a proxy configured
```shell
  rake connect
  dockerup -t forj/redstone:gerrit --opts "--env PROXY=" -n "gerrit.42.localhost" -c
  # observice the fqdn
  facter fqdn
```

## Using dockerup
dockerup is a shell alias used on vm's for making it easier to interact with
docker and the images we'll create with blueprints.

to get started either use ```rake dev``` where the dockerup alias is automatically
setup, or setup the alias with the command ```alias dockerup=./docker_up.sh```

To get help run: ```dockerup -h```

## TODO
* we need a docker_runit.sh script that will start all our containers.
* we need to implement the version tagging on docker_prepare.sh
* we need a tagging schema for all containers.
* we need a docker_install_registry.sh script to install a private registry.
* we need to extract the docker_install.sh script from the Vagrantfile and call it as a provisioner script.
* we need to start the ruby library to integrate forj-cli, and it's rake specs.
* we need test cases for each of the top level scripts.
* thoughts about giving dockerup the ability to transfer meta.js to docker image using --env settings??

#License
forj-docker is licensed under the Apache License, Version 2.0.  See LICENSE for full license text.
