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
SCRIPT_NAME=$0
SCRIPT_DIR="$(dirname $SCRIPT_NAME)"
SCRIPT_FULL_DIR="$(cd $SCRIPT_DIR;pwd)"
#
# source all common script functions
#
for i in ${SCRIPT_FULL_DIR}/src/common/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
done
unset i


#
# build a docker image with specified docker file
# use DOCKER_HOME as the docker build context
# <Dockerfile Name>  <image name>
#
function DOCKER_BUILD {
    [ -z "${1}" ] && ERROR_EXIT  ${LINENO} "DOCKER_BUILD requires 1st argument, the docker file name in DOCKER_HOME." 2
    [ -z "${2}" ] && ERROR_EXIT  ${LINENO} "DOCKER_BUILD requires 2nd argument, the docker image name." 2
    [ -z "${DOCKER_HOME}" ] && ERROR_EXIT  ${LINENO} "no DOCKER_HOME defined" 2
    DOCKER_NAME=$2
    # use sg
    # workaround to error:
    # Get http:///var/run/docker.sock/v1.14/info: dial unix /var/run/docker.sock: permission denied
    _CWD=$(pwd)
    cd "${DOCKER_HOME}"
    [ -f Dockerfile ] && rm -f Dockerfile
    ln -s "$1" Dockerfile
    if ! groups | grep docker > /dev/null 2<&1 ; then
      ERROR_EXIT ${LINENO} "The current user is not a member of the docker group" 2
    fi
    sg docker -c "docker build -t '${DOCKER_NAME}' '${DOCKER_HOME}'"
    DOCKER_REPO=$(echo "${DOCKER_NAME}"|awk -F: '{print $1}')
    DOCKER_TAG=$(echo "${DOCKER_NAME}"|awk -F: '{print $2}')
    if ! sg docker -c "docker images --no-trunc | grep -e '^${DOCKER_REPO}\s*${DOCKER_TAG}.*'" ; then
      ERROR_EXIT ${LINENO} "${DOCKER_NAME} image not found." 2
    fi
    cd "${_CWD}"
}

#
# for every Dockerfile.* in the docker directory create a DOCKER_BUILD
for i in $(find "${SCRIPT_FULL_DIR}/docker" -type f -name 'Dockerfile.*' ); do
    echo "Working on => $i"
    # get the DOCKER-NAME from the Dockerfile.* file, otherwise skip it.
    DOCKER_NAME=$(grep DOCKER-NAME $i | awk '{print $3}')
    if [ ! -z $DOCKER_NAME ]; then
      echo "Image name => ${DOCKER_NAME}"
      export DOCKER_HOME=$(dirname $i)
      DOCKER_FILE=$(basename $i)
      DOCKER_BUILD ${DOCKER_FILE} ${DOCKER_NAME}
      #TODO: lets implement a DOCKER_TAG function so we can give the build
      #      alternate tag names that include the version and latest, like
      #      forj/redstone:gerrit-latest -> forj/redstone:gerrit-1.0.1 -> forj/redstone:gerrit
      # goal is to be able to have 
    else
      echo "Could not find DOCKER-NAME for $i, skipping"
    fi
done
unset i
