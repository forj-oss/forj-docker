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
# DEBUGGING set -x -v
SCRIPT_NAME=$0
SCRIPT_DIR="$(dirname $SCRIPT_NAME)"
SCRIPT_FULL_DIR="$(cd $SCRIPT_DIR;pwd)"
CONTAINER_NAME=forj-docker-registry
# note: be mindful when you change this value (see docker_reg_setup.sh)
REPO_NAME=forj/docker
IMAGE=registry
IMAGE_TAG=$REPO_NAME:$IMAGE
LOCAL_STORAGE=${DOCKER_WORKAREA:-"$(pwd)/docker-registry/data"}
REGISTRY_PORT=${REGISTRY_PORT:-80}
BASE_STORAGE_PATH="/opt/docker/data"


#
# source all common script functions
#
for i in ${SCRIPT_FULL_DIR}/common/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
done
unset i
[ -z "$(docker --version 2> /dev/null)" ] && \
    ERROR_EXIT ${LINENO} "failed to execute start docker registry" 2

[ -z "$(docker images -a | egrep "^${REPO_NAME}.*${IMAGE}")" ] && \
    ERROR_EXIT ${LINENO} "${IMAGE_TAG} not found, try building it with rake registry_build" 2

if [ -z "$(docker inspect ${CONTAINER_NAME} 2> /dev/null | egrep '.*Running.*true')" ] ; then

    echo "Registry data will be stored : ${LOCAL_STORAGE}"

    if [ -z "$(docker inspect ${CONTAINER_NAME} 2> /dev/null | egrep '.*Running.*false')" ] ; then
        _SESSION=$(docker run -d -p $REGISTRY_PORT:5000 \
                      -v ${LOCAL_STORAGE}:${BASE_STORAGE_PATH} \
                      -e STORAGE_PATH=${BASE_STORAGE_PATH}/registry \
                      -e SEARCH_BACKEND=sqlalchemy \
                      --name="${CONTAINER_NAME}" \
                  ${IMAGE_TAG})
        [ ! $? -eq 0 ] && ERROR_EXIT ${LINENO} "failed to execute start docker registry ${IMAGE_TAG}" 2
    else
        docker start $CONTAINER_NAME
        [ ! $? -eq 0 ] && ERROR_EXIT ${LINENO} "failed to execute docker start ${CONTAINER_NAME}" 2
    fi

else
    WARN ${LINENO} "${CONTAINER_NAME} is already running on this system."
fi

echo "checking startup with : docker logs ${CONTAINER_NAME}"
docker logs ${CONTAINER_NAME} 2>&1 | head -4
[ ! $? -eq 0 ] && ERROR_EXIT ${LINENO} "failed to execute start docker logs ${CONTAINER_NAME}" 2
echo "..... log trimed .... "
docker logs ${CONTAINER_NAME} 2>&1 | tail -4
[ ! $? -eq 0 ] && ERROR_EXIT ${LINENO} "failed to execute start docker logs ${CONTAINER_NAME}" 2

echo "check top with : docker top ${CONTAINER_NAME}"
exit 0
