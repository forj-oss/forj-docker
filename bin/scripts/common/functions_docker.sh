#!/bin/bash
# Copyright 2013 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#

#
# shell scripts for interacting with docker cli in bash scripts
#

# docker default config file
function DOCKER_DEFAULTS {
    echo -n '/etc/default/docker'
}

#
# restart docker services
function DOCKER_RESTART {
  echo 'Restarting docker service'
  DO_SUDO service docker restart
  return 0
}

#
# DOCKER_GRANT_ACCESS 'username'
# grant access to current user or passed in user
function DOCKER_GRANT_ACCESS {
  if [ -z "${1}" ] ; then
    CURRENT_USER=$(facter id)
  else
    CURRENT_USER=$1
  fi
  [ -z "${CURRENT_USER}" ] && ERROR_EXIT ${LINENO} "failed to get current user with facter id" 2
  DO_SUDO puppet apply $PUPPET_DEBUG \
  -e "user {'${CURRENT_USER}': ensure => present, gid => 'docker' }"
}

#
# docker configure proxy
function DOCKER_PROXY_CONF {
  # check if the local docker config has /etc/default/docker configured
  # for http_proxy
  if [ ! -z "$HTTP_PROXY" ]; then
    egrep ".*export\shttp_proxy=\"${HTTP_PROXY}\"" "$(DOCKER_DEFAULTS)" ||
    DO_SUDO sed -n -i '/.*export\shttp_proxy=.*/!p' "$(DOCKER_DEFAULTS)" &&
    DO_SUDO bash -c "echo \"export http_proxy=\"${HTTP_PROXY}\"\" >> \"$(DOCKER_DEFAULTS)\"" &&
    DOCKER_RESTART
  fi
}
