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
SCRIPT_DIR="$(dirname "${SCRIPT_NAME}")"
SCRIPT_FULL_DIR="$(cd "${SCRIPT_DIR}";pwd)"
#
# source all common script functions
#
for i in ${SCRIPT_FULL_DIR}/common/*.sh; do
    if [ -r "${i}" ]; then
      . "${i}"
    fi
done
unset i

#
# grant access
#
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
# grab maestro repo and clone
#
[ ! -d "${SCRIPT_FULL_DIR}/git" ] && mkdir -p "${SCRIPT_FULL_DIR}/git"
cd "${SCRIPT_FULL_DIR}/git"
[ ! -d maestro/.git ] && git clone https://review.forj.io/forj-oss/maestro
DO_SUDO bash maestro/puppet/install_puppet.sh

puppet --version
[ ! $? -eq 0 ] && ERROR_EXIT ${LINENO} "failed to execut puppet --version" 2

MODULE_LIST=$(DO_SUDO puppet module list)
MODULE_NAME="garethr-docker"
MODULE_VERSION="${PUPPET_DOCKER_VERSION:-2.2.0}"
if ! echo "${MODULE_LIST}" | grep "${MODULE_NAME} ([^v]*v${MODULE_VERSION}" >/dev/null 2>&1
  then
  # Attempt module upgrade. If that fails try installing the module.
  _VERSION_OPT=''
  [ ! "${MODULE_VERSION}" = "latest" ] && _VERSION_OPT="--version ${MODULE_VERSION}"
  if ! DO_SUDO puppet module upgrade ${MODULE_NAME} ${_VERSION_OPT} >/dev/null 2>&1
    then
    # This will get run in cron, so silence non-error output
    DO_SUDO puppet module install ${MODULE_NAME} ${_VERSION_OPT} >/dev/null
  fi
fi

#
# OS Patch section
#
# PATCH for http://stackoverflow.com/questions/27216473/docker-1-3-fails-to-start-on-rhel6-5
# sudo yum-config-manager --enable public_ol6_latest
# sudo yum install device-mapper-event-libs
if [ "$(facter osfamily)" = "RedHat" ] && [ "$(facter operatingsystemrelease)" = "6.5" ]; then
    _CWD=$(pwd)
    DO_SUDO yum-config-manager --enable public_ol6_latest
    DO_SUDO yum install device-mapper-event-libs
    cd /etc/yum.repos.d
    DO_SUDO wget public-yum.oracle.com/public-yum-ol6.repo
    DO_SUDO wget public-yum.oracle.com/RPM-GPG-KEY-oracle-ol6 -O /etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
    DO_SUDO yum update device-mapper -y
    cd "${_CWD}"
fi
#
# install docker
#
DOCKER_VERSION=${DOCKER_VERSION:-1.4.1}
[ ! -z "${http_proxy}" ] && proxy_str="proxy => '${http_proxy}',  no_proxy => '${no_proxy}',"
version_str="version => '${DOCKER_VERSION}', "
echo "running command : puppet apply --modulepath=/etc/puppet/modules
--debug --verbose
-e class{'docker':
${version_str}
${proxy_str}
}"
DO_SUDO puppet apply --modulepath=/etc/puppet/modules \
    --debug --verbose -e "class{'docker': ${version_str} ${proxy_str} }"
docker --version

#
# grant docker access and dockerup alias
#
[ ! $? -eq 0 ] && ERROR_EXIT ${LINENO} "failed to execut docker --version" 2
[ ! "$(id -u)" -eq "0" ] && DOCKER_GRANT_ACCESS
[ ! -z "$1" ] && DOCKER_GRANT_ACCESS $1
DO_SUDO bash -c 'echo "alias dockerup='${SCRIPT_FULL_DIR}'/docker_up.sh" > /etc/profile.d/dockerup.sh'
DO_SUDO chmod a+x /etc/profile.d/dockerup.sh

#
# pull the default repos
#
docker pull ubuntu:precise
docker pull forj/ubuntu:precise
docker pull forj/ubuntu:trusty
