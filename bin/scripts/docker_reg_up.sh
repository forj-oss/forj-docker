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
CONTAINER_NAME=forj-reg
# note: be mindful when you change this value (see docker_reg_setup.sh)
IMAGE_TAG=registry
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

# clone Docker registry container
if [ -n "$BASE_STORAGE_PATH" ] ; then
    # override ENV data from iimage's Dockerfile
    docker run -d -p 5000:5000 -e ${BASE_STORAGE_PATH}/registry --name="${CONTAINER_NAME}" ${IMAGE_TAG}
  else
    # use ENV data from image's Dockerfile
    docker run -d -p 5000:5000 --name="${CONTAINER_NAME}" ${IMAGE_TAG}
fi
[ ! $? -eq 0 ] && ERROR_EXIT ${LINENO} "failed to execute start docker registry" 2
