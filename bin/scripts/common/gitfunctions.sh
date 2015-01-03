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
# clone or update a project repo based on REVIEW_SERVER and GIT_HOME
#
function GERRIT_GIT_CLONE {
  [ -z "${1}" ] && ERROR_EXIT  ${LINENO} "GIT_CLONE requires repo name" 2
  [ -z "${REVIEW_SERVER}" ] && ERROR_EXIT  ${LINENO} "GIT_CLONE requires REVIEW_SERVER" 2
  [ -z "${GIT_HOME}" ] && ERROR_EXIT  ${LINENO} "no GIT_HOME defined" 2
  git config --global http.sslverify false
  if [ ! -d "${GIT_HOME}/${1}/.git" ] ; then
    if ! git clone --depth=1 "${REVIEW_SERVER}/p/${1}" "${GIT_HOME}/${1}" ; then
      echo "Retrying clone operation on $REVIEW_SERVER/p/$1"
      git clone --depth=1 "${REVIEW_SERVER}/p/${1}" "${GIT_HOME}/${1}"
    fi
  fi
  _CWD="$(pwd)"
  cd "${GIT_HOME}/${1}"
  git branch -a > /dev/null 2<&1
  git reset --hard HEAD
  git remote update
  if ! git remote update ; then
    echo "Retrying remote update operation on $GIT_HOME/$1"
    git remote update
  fi
  cd "${_CWD}"
  return 0
}

#
# clone a repo from url
# GIT_CLONE <url> <destination>
# use HTTP_SSL_VERIFY_OFF env to ignore ssl url's
#
function GIT_CLONE {
  [ -z "${1}" ] && ERROR_EXIT  ${LINENO} "GIT_CLONE requires url" 2
  [ -z "${2}" ] && ERROR_EXIT  ${LINENO} "GIT_CLONE requires destination" 2
  [ ! -z "${HTTP_SSL_VERIVY_OFF}" ] && git config --global http.sslverify false
  if [ ! -d "${2}/.git" ] ; then
    if ! git clone --depth=1 "${1}" "${2}" ; then
      echo "Retrying clone operation on ${1}"
      git clone --depth=1 "${1}" "${2}"
      [ ! $? -eq 0 ] && ERROR_EXIT ${LINENO} "FAILED to clone ${1}"
    fi
  fi
  _CWD="$(pwd)"
  cd "${2}"
  git branch -a > /dev/null 2<&1
  git reset --hard HEAD
  git remote update
  if ! git remote update ; then
    echo "Retrying remote update operation on $2"
    git remote update
  fi
  cd "${_CWD}"
  return 0
}
