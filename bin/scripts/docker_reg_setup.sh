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

# clone Docker registry container
git clone https://github.com/docker/docker-registry.git
[ ! $? -eq 0 ] && ERROR_EXIT ${LINENO} "failed to execute git clone of docker registry" 2
# build the image
docker build -rm -t forj/docker:registry .
[ ! $? -eq 0 ] && ERROR_EXIT ${LINENO} "failed to execute docker registry build" 2
