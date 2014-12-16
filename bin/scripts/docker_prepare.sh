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
SCRIPT_DIR="$(dirname "${SCRIPT_NAME}")"
SCRIPT_FULL_DIR="$(cd "${SCRIPT_DIR}";pwd)"
[ ! -z "$DOCKER_WORKAREA" ] && echo "DOCKER_WORKAREA passed in ==> ${DOCKER_WORKAREA}"
DOCKER_WORKAREA=${DOCKER_WORKAREA:-"${SCRIPT_FULL_DIR}/../../docker"}
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
# get forj-docker path
#
function GET_FORJ_DOCKER_PATH {
  _FORJ_DOCKER_PATH=$(which forj-docker)
  if [ "$_FORJ_DOCKER_PATH" = "" ] ; then
      # use forj-docker from source
      _FORJ_BIN="$(cd "${SCRIPT_FULL_DIR}"; cd ..; pwd)"
      _FORJ_DOCKER_PATH="${_FORJ_BIN}/forj-docker"
  fi
  if [ -f "${_FORJ_DOCKER_PATH}" ]; then
      echo -n "${_FORJ_DOCKER_PATH}"
  else
      echo -n "forj-docker"
  fi
}

#
# build a docker image with specified docker file
# use DOCKER_HOME as the docker build context
# <Dockerfile Name>  <image name>
#
function DOCKER_BUILD {
    [ -z "${1}" ] && ERROR_EXIT  ${LINENO} "DOCKER_BUILD requires 1st argument, the docker file name in DOCKER_HOME." 2
    [ -z "${2}" ] && ERROR_EXIT  ${LINENO} "DOCKER_BUILD requires 2nd argument, the docker image name." 2
    [ -z "${DOCKER_HOME}" ] && ERROR_EXIT  ${LINENO} "no DOCKER_HOME defined" 2
    DOCKER_FILE_NAME="${1}"
    DOCKER_FILE_DIR="$(dirname "${DOCKER_FILE_NAME}")"
    DOCKER_NAME=$2
    # use sg
    # workaround to error:
    # Get http:///var/run/docker.sock/v1.14/info: dial unix /var/run/docker.sock: permission denied
    _CWD=$(pwd)
    cd "${DOCKER_HOME}"
    [ -f Dockerfile ] && rm -f Dockerfile
    # Setup docker source folder
    ln -s "${DOCKER_FILE_NAME}" Dockerfile
    if [ -e "${DOCKER_FILE_DIR}/setup_sources.sh" ] ; then
      chmod a+x "${DOCKER_FILE_DIR}/setup_sources.sh"
      bash -c "${DOCKER_FILE_DIR}/setup_sources.sh ${SCRIPT_FULL_DIR}"
      [ ! $? -eq 0 ] && ERROR_EXIT  ${LINENO} "DOCKER_BUILD ${DOCKER_FILE_DIR}/setup_sources.sh failed to execute." 2
    fi

    # validate we can run docker commands
    if ! groups | grep docker > /dev/null 2<&1 ; then
      ERROR_EXIT ${LINENO} "The current user is not a member of the docker group" 2
    fi
    #
    # setup build time configuration
    cat > build/build_00.sh << BUILD_SETTINGS
    [ ! -z "${PROXY}" ] && export PROXY="${PROXY}"
    [ ! -z "${http_proxy}" ] && export PROXY="${http_proxy}"
    echo "build settings done."
BUILD_SETTINGS
    chmod a+x build/build_00.sh

    # build and check the docker image
    sg docker -c "docker build -t '${DOCKER_NAME}' '${DOCKER_HOME}'"
    DOCKER_REPO=$(echo "${DOCKER_NAME}"|awk -F: '{print $1}')
    DOCKER_TAG=$(echo "${DOCKER_NAME}"|awk -F: '{print $2}')
    if ! sg docker -c "docker images --no-trunc | grep -e '^${DOCKER_REPO}\s*${DOCKER_TAG}.*'" ; then
      ERROR_EXIT ${LINENO} "${DOCKER_NAME} image not found." 2
    fi
    cd "${_CWD}"
}

#
# process all Dockerfile.*.erb files using forj-docker
# in current DOCKER_WORKAREA
#
function PROCESS_TEMPLATES
{
    FORJ_DOCKER_BIN=$(GET_FORJ_DOCKER_PATH)
    if [ "$($FORJ_DOCKER_BIN version)" = "" ]; then
        echo "ERROR: in forj-docker location, no $FORJ_DOCKER_BIN"
        echo "        command found, can't process templates"
        return
    fi
    find "${DOCKER_WORKAREA}" -type f -name 'Dockerfile.*.erb' | while IFS= read -r i;
    do
        echo "Convert template => $i"
        _target=$(dirname "${i}")/$(basename "${i}" '.erb')
        JSON_CONFIG=${JSON_CONFIG:-""}
        if [ -z "${JSON_CONFIG}" ]; then
            $FORJ_DOCKER_BIN template "$i" "$_target"
            _res=$?
        else
            $FORJ_DOCKER_BIN template "$i" "$_target" -c "${JSON_CONFIG}"
            _res=$?
        fi
        if [ ! "$_res" = "0" ]; then
            echo "ERROR with executing $FORJ_DOCKER_BIN"
            echo "      working on $i -> $_target"
            exit $_res
        fi
    done
    unset i
}

#
# process all Dockerfile.* and not erb files in current DOCKER_WORKAREA
#
function PROCESS_WORKAREA
{
  #
  # for every Dockerfile.* in the docker directory create a DOCKER_BUILD
  find "${DOCKER_WORKAREA}" -type f -name 'Dockerfile.*' ! -name '*.erb' | while IFS= read -r i;
  do
      echo "Working on => $i"
      # get the DOCKER-NAME from the Dockerfile.* file, otherwise skip it.
      DOCKER_NAME=$(grep DOCKER-NAME "${i}" | awk '{print $3}')
      if [ ! -z "${DOCKER_NAME}" ]; then
          echo "Image name => ${DOCKER_NAME}"
          export DOCKER_HOME=$(dirname "${i}")
          DOCKER_FILE=$(basename "${i}")
          DOCKER_BUILD "${DOCKER_FILE}" "${DOCKER_NAME}"
          #TODO: lets implement a DOCKER_TAG function so we can give the build
          #      alternate tag names that include the version and latest, like
          #      forj/redstone:gerrit-latest -> forj/redstone:gerrit-1.0.1 -> forj/redstone:gerrit
          # goal is to be able to have
      else
          echo "Could not find DOCKER-NAME for $i, skipping"
      fi
  done
  unset i
}

PROCESS_TEMPLATES
PROCESS_WORKAREA
