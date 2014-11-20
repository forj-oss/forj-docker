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
echo "setup sources"
_ARGS_PROJECT_HOME="${1}"
export PROJECT_HOME=${_ARGS_PROJECT_HOME:-""}
if [ -z "${PROJECT_HOME}" ] ; then
  echo "skippping sources because first argument is empty for PROJECT_HOME"
  exit 1
fi
SCRIPT_NAME=$0
SCRIPT_DIR="$(dirname $SCRIPT_NAME)"
SCRIPT_FULL_DIR="$(cd $SCRIPT_DIR;pwd)"
_CWD=$(pwd)
# setup so all commands are relative to the Dockerfile
cd "${SCRIPT_FULL_DIR}"

# setup our proxy files
[ -d build ] && rm -rf build
mkdir build
cp "${PROJECT_HOME}/proxy.sh" build/proxy_01.sh

cd "${_CWD}"
