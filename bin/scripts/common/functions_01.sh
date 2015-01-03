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
export DEBUG=${DEBUG:-0}
export SCRIPT_TEMP=$(mktemp -d)
export AS_ROOT=${AS_ROOT:-0}

[ "${DEBUG}" -eq 1 ] && set -x -v
trap 'rm -rf $SCRIPT_TEMP' EXIT

#
# function to trap an error and exit
#
function ERROR_EXIT {
  _line="$1"
  _errm="$2"
  _code="${3:-1}"
  if [ ! -z "$_errm" ] ; then
    echo "ERROR (${_line}): ${_errm}, exit code ${_code}" 1>&2
  else
    echo "ERROR (${_line}): exit code ${_code}" 1>&2
  fi
  exit "${_code}"
}
trap 'ERROR_EXIT ${LINENO}' ERR

#
# run a sudo command if the script is not run as root
# otherwise run the command, assume we're root
# AS_ROOT can be used to force no sudo execution when set to something other
# than 0.
#
function DO_SUDO {
  if [[ ! $(id -u) -eq 0 && $AS_ROOT -eq 0 ]]; then
    sudo "$@"
  else
    "$@"
  fi
}
