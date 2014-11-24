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
# <docker_install.sh> <dockeruser>
SCRIPT_NAME=$0
SCRIPT_DIR="$(dirname $SCRIPT_NAME)"
SCRIPT_FULL_DIR="$(cd $SCRIPT_DIR;pwd)"
#
# source all common script functions
#
for i in ${SCRIPT_FULL_DIR}/common/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
done
unset i

#
# grant access
#
function DOCKER_GRANT_ACCESS {
  if [ -z $1 ] ; then
    CURRENT_USER=$(facter id)
  else
    CURRENT_USER=$1
  fi
  [ -z $CURRENT_USER ] && ERROR_EXIT ${LINENO} "failed to get current user with facter id" 2
  DO_SUDO puppet apply $PUPPET_DEBUG \
  -e "'"'user {'${CURRENT_USER}': ensure => present, gid => 'docker' }'"'"
}

#
# grab maestro repo and clone
#
[ ! -d "${SCRIPT_FULL_DIR}/git" ] && mkdir -p "${SCRIPT_FULL_DIR}/git"
cd "${SCRIPT_FULL_DIR}/git"
[ ! -d maestro/.git ] && git clone https://review.forj.io/forj-oss/maestro
DO_SUDO bash maestro/puppet/install_puppet.sh

puppet --version
[ ! $? -eq 0 ] && ERROR_EXIT ${LINENO} "failed to execut puppet --version" 2
[[ ! $(puppet module list | grep 'garethr-docker' ) ]] && puppet module install garethr-docker
[ ! -z "${http_proxy}" ] && proxy_str="proxy => '${http_proxy}',  no_proxy => '${no_proxy}',"
echo "running command : puppet apply --modulepath=/etc/puppet/modules
--debug --verbose
-e class{'docker':
${proxy_str}
}"

DO_SUDO puppet apply --modulepath=/etc/puppet/modules \
    --debug --verbose -e '"'class{'docker': ${proxy_str} }'"'

docker --version
[ ! $? -eq 0 ] && ERROR_EXIT ${LINENO} "failed to execut docker --version" 2
[ ! "$(id -u)" -eq "0" ] && DOCKER_GRANT_ACCESS
[ ! -z "$1" ] && DOCKER_GRANT_ACCESS $1
DO_SUDO echo '"'alias dockerup=${SCRIPT_FULL_DIR}/bin/scripts/docker_up.sh'"' > /etc/profile.d/dockerup.sh
DO_SUDO chmod a+x /etc/profile.d/dockerup.sh

#
# pull the default repos
#
docker pull ubuntu:precise
docker pull forj/ubuntu:precise
docker pull forj/ubuntu:trusty
