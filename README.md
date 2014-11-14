
We are experimenting with vagrant.  This project will use maestro and redstone
 to setup docker images locally that can be used to start/stop docker images
 for each node.  Currently redstone requires 4 nodes.  We will use one 
 container for each node.   
 maestro - provies a ui that allows you to navigate to each node.
 gerrit  - provides an scm service for git
 ci      - provides a jenkins build service
 util    - provides for utility services like paste and logstash

 Status for this work is experimental.

* setup a vm for docker images
  vagrant up
* prepare all docker images in the docker folder
   vagrant ssh
   docker_prepare.sh
* Start a gerrit server
   vagrant ssh
   dockerup -a gerrit -t forj/redstone:gerrit -n gerrit.42.localhost

