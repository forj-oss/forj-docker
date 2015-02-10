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

#
# determine the linux distribution isntalled
function is_rhel6 {
    [ -f /usr/bin/yum ] && \
        cat /etc/*release | grep -q -e "Red Hat" -e "CentOS" && \
        cat /etc/*release | grep -q 'release 6'
}

function is_ubuntu {
    [ -f /usr/bin/apt-get ]
}

#
# determine docker default config file
function DOCKER_DEFAULTS {
    if is_rhel6; then
        echo -n '/etc/sysconfig/docker'
    elif is_ubuntu; then
        echo -n '/etc/default/docker'
    else
        echo "***Can not determine the docker env default location: distribution not recognized"
        exit 1
    fi
}

#
# restart docker services
function DOCKER_RESTART {
    echo 'Restarting docker service'
    DO_SUDO service docker restart
    timeout=0
    until docker images > /dev/null 2<&1 || [ $timeout -eq 4 ]; do
        sleep $(( timeout++ ))
    done
    docker images > /dev/null 2<&1 ||
    (echo 'failed to start docker service' && return 1)
    echo 'docker service restarted'
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
      if ! egrep ".*export\shttp_proxy=\"${HTTP_PROXY}\"" "$(DOCKER_DEFAULTS)" ; then
          DO_SUDO sed -n -i '/.*export\shttp_proxy=.*/!p' "$(DOCKER_DEFAULTS)"
          DO_SUDO bash -c "echo \"export http_proxy=\\\"${HTTP_PROXY}\\\"\" >> \"$(DOCKER_DEFAULTS)\""
          DOCKER_RESTART
      fi
  else
      if egrep ".*export\shttp_proxy=.*" "$(DOCKER_DEFAULTS)" ; then
          DO_SUDO sed -n -i '/.*export\shttp_proxy=.*/!p' "$(DOCKER_DEFAULTS)"
          echo 'removing proxy conf from docker'
          DOCKER_RESTART
      fi
  fi
}

#
# docker configure dns settings
# see workaround: https://robinwinslow.co.uk/2014/08/27/fix-docker-networking/
function DOCKER_DNS_CONF {
    # TODO : need redhat implementation
    NM_TOOL=$(which nm-tool)
    if [ -z "${NM_TOOL}" ]; then
      echo "WARNING skipping DOCKER_DNS_CONF, cant find nm-tool"
      echo "try installing ; apt-get install network network-manager"
      return
    fi
    [ ! -f "${NM_TOOL}" ] && ERROR_EXIT ${LINENO} "nm-tool not found for dns." 2
  # we will setup local dns first, then google public dns second.
    LOCAL_DNS=$( "${NM_TOOL}" 2>&1 |grep -v WARNING | grep DNS | \
                 awk -F: '{print $2}'| \
                 sed -e 's/^ *//g' -e 's/ *$//g'| \
                 awk '{print "--dns "$1}' ORS=' ')
    # external fall back to google dns
    LOCAL_DNS="${LOCAL_DNS} --dns 8.8.8.8"
    egrep "^DOCKER_OPTS=\"\\$\\{DOCKER_OPTS\\}\s${LOCAL_DNS}\"" \
        "$(DOCKER_DEFAULTS)" ||
        ( echo 'Configure docker dns settings' &&
          DO_SUDO sed -n -i '/^DOCKER_OPTS=\"\${DOCKER_OPTS}\s--dns.*/!p' \
              "$(DOCKER_DEFAULTS)" &&
          DO_SUDO bash -c \
           "echo \"DOCKER_OPTS=\\\"\\\${DOCKER_OPTS} ${LOCAL_DNS}\\\"\" >> \"$(DOCKER_DEFAULTS)\"" &&
           DOCKER_RESTART )
}
