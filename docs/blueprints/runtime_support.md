::

  Copyright 2014 Hewlett-Packard Development Company, L.P.

  This work is licensed under a Creative Commons Attribution 3.0
  Unported License.
  http://creativecommons.org/licenses/by/3.0/legalcode

..

=======================================================
support for forj-docker runtime execution of containers
=======================================================

forj-docker needs a facility to initiate running containers for forj blueprints.

Problem
=======

There are many execution environments that can support starting / stopping containers indivdually and as a service.

We need to create a system by which we can execute runtime environments for forj docker processing such as ; kubernetes, fig, or other runtime execution environments.

This enables forj to stand up blueprints within containers and leverage container technology.

Proposed Change
===============
Lets use lorj library to create controllers for each runtime executor in forj-docker library.

This will primarily drive calles to docker orchestration solutions such as:
* FIG (www.fig.sh)  (good for single docker container and for Dev environments. Falls short at multi container development)
* Kubernetes https://github.com/googlecloudplatform/kubernetes
* Others, hp??

Integration
-----------
forj cli should have a plugin that knows how to have an interactive execution of forj-docker calls, so we have a single point of entry for end-user consumption.

Examples: i want to install docker and configure it for forj-docker.
        run : forj setup <account> -a docker
        and execute forj boot redstone -a <account>
* this prompts through configuration of forj-docker gem
* now we can use forj boot -a docker , to boot a new docker instance with forj-docker run commands

forj-docker and forj cli would then share the same lorj based process for container start/stop/run operations.
run - it means the container has never previously run, run a new instance.
start - means the conatiner has run at least once before, restart that session.
stop - means stop the running instance of the container.

forj-docker should have a way to distinguish when containers are built with forj-docker or not, so we can perform custom actions if needed.

forj cli as well as forj docker needs to use lorj docker processing to do what it needs to do on each container it runs.

forj cli is targeted for end users wanting to deploy blueprints to clouds using dockerized containers of the blueprints.

forj docker is targeted at managing the life cycle of those containers and enabling single host execution of containers for local runtime environments using runtime provider specified.

Alternatives
------------
* do nothing, let operations team manage containers without orchestration help for containers.  Issue here is that there would be many ways to solve the same problem.

Implementation
==============
* Model(Model a service, different objects, with different attributes to manage the different services you want to expose) for lorj in forj-docker:
 * We need the controllers written in forj-docker that will connect fix, kub
 * simple shell, localhost controller, for script based container startup.
* Create controller templates in forj-docker.

Assignee(s)
-----------
* chrisssss
* wenlock
* miqui
* che-arne
* luis

Work Items
----------
* create lorj-docker gem project and specs
* create models in lorj-docker gem
* create controllers in forj-docker gem
* create controller for shell based run / stop commands
* create controller for kub
* create controller for fig
* document possiblity for other controllers

Repositories
------------

Servers
-------

External CI requirements
-------------------------
* docker registry hosting??

Documentation
-------------

Security
--------

Testing
-------

Use Cases
---------
* I'm a developer and i want to run a blueprint on my laptop using forj-docker.   I need a command to execute:
    forj-docker configure provider fig; rake run;
** Expected result is that the blueprint in the current directory described by the Rakefile, executes the redstone or whatever blueprint i have configured.
* I'm setting up a production system to use docker containers, and I want to run all the static servers defined by my blueprint.   I should be able to do something like:
    rake start
** Expected Result, forj-docker takes care of scheduling my blueprint to rake run, and keep the containers running perpetually.
* I have test cases that require a running blueprint.   I want to run serverspec, or spec test cases against that blueprint.   I should be able to do ```rake test```, and see that execute rake run along with any spec test cases in the spec folder , and shutdown my running containers after the test is done.

Os support
----------
* Windows 2008 R2 (with Vagrant, not boot2docker <--- why not? sure, why not) deserves some looking into
* Ubuntu 14.04  (first class citizen)
* Redhat 6.5 with patches  (first class)
* Redhat 7.0 vanilla
* Fedora 20 or 21
* Centos 7

Dependencies
============
