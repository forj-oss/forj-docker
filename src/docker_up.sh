#!/bin/bash
# (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

RUNTIME_HOME=~
usage()
{
  cat <<EOF

  usage: $0 options

  This script will start a docker container

  OPTIONS:
    -a | --auto {name}      : look for last attached docker, start it if not running. use name for new sessions.
    -c | --clear            : when used with -a , clears previous session and starts a new one.
    -t | --container {name} : optional container name, otherwise defaults to ${RUNTIME_HOME}/.docker_container contents
                              changes default container name as well in ${RUNTIME_HOME}/.docker_container
    -o | --opts <options>   : docker options
    -n | --name <name>      : name of the host container
    -h | --help             : help

EOF
}

# Read in Complete Set of Coordinates from the Command Line
_options=
_hostname=
OPTION=
_auto=0
_clear=0
_CONTAINER=ubuntu\:12.04
if [ -f ${RUNTIME_HOME}/.docker_container ] ; then
    _CONTAINER=$(cat ${RUNTIME_HOME}/.docker_container)
    [[ -z "$_CONTAINER" ]] && echo "WARNING: ${RUNTIME_HOME}/.docker_container is empty, setting to default. ubuntu:12.04, otherwise use -t to set to another value."
    [[ -z "$_CONTAINER" ]] && _CONTAINER=ubuntu\:12.04
else
    echo -n $_CONTAINER > ${RUNTIME_HOME}/.docker_container
fi
while [[ $# -gt 0 ]]; do
  opt="$1"
  shift;
  current_arg="$1"

  [[ "$current_arg" =~ ^-{1,2}.* ]] && \
  [[ ! "$opt" = "-opt" ]] && \
  [[ ! "$opt" = "--opts" ]] && \
  [[ ! "$current_arg" = "-c" ]] && \
  [[ ! "$current_arg" = "--clear" ]] && \
    echo "WARNING: You may have left an argument blank. Double check your command." && \
    echo "         or move -c option to the end." && \
    echo " DEBUG:  current_arg => ${current_arg}" && \
    echo " DEBUG:  opt => ${opt}"

  case "$opt" in
    "-h"|"--help"       ) usage; exit 1;;
    "-a"|"--auto"       ) _auto=1;_auto_name="$1"; shift;;
    "-c"|"--clear"      ) _clear=1;;
    "-t"|"--container"  ) _arg_container=$1; shift;;
    "-n"|"--name"       ) _hostname="$1"; shift;;
    "-o"|"--opts"       ) _options="$1"; shift;;
    *                   ) echo "ERROR: Invalid option: \""$opt"\"" >&2;
    usage;
    exit 1;;
  esac
  [ "$_auto_name" = "-c" ] || [ "$_auto_name" = "--clear" ] && _clear=1
  [[ "$_auto_name" =~ ^-{1,2}.* ]] && _auto_name=""
done
if [ ! "$_CONTAINER" = "$_arg_container" ] ; then
    _CONTAINER=$_arg_container
    [[ -z "$_CONTAINER" ]] && echo "WARNING: container arg is empty, setting to default. ubuntu:12.04"
    [[ -z "$_CONTAINER" ]] && _CONTAINER=ubuntu\:12.04
    echo -n $_CONTAINER > ${RUNTIME_HOME}/.docker_container
fi

[[ $_auto = 1 ]] && [[ -z $_auto_name ]] && _auto_name=auto
function dirnamef
{
_cwd=$(pwd); _dir=$(dirname $1);
cd $_dir && _dir=$(git rev-parse --show-toplevel)
cd $_dir/..
  _dir=$(pwd)
  cd $_cwd
  echo -n $_dir
}

#
# setup the volumes to attach, default /opt/workspace/home
#
_VOLUMES="-v $(dirnamef $0):/opt/workspace/home:rw"

#
# setup the default hostname for the box
#
if [ "${_hostname}" = "" ] ; then
  _hostname=noname.42.localhost
fi

#
# setup the default environments we will configure
#
cat > ${RUNTIME_HOME}/.docker_auto.env << DOCKER_ENV
PROXY=${PROXY}
http_proxy=${http_proxy}
https_proxy=${https_proxy}
HTTP_PROXY=${HTTP_PROXY}
HTTPS_PROXY=${HTTPS_PROXY}
ftp_proxy=${ftp_proxy}
socks_proxy=${socks_proxy}
no_proxy=${no_proxy}
DOCKER_ENV

if [ -f ${RUNTIME_HOME}/.docker.env ]; then
    _options="--env-file ${RUNTIME_HOME}/.docker.env ${_options}"
else
    _options="--env-file ${RUNTIME_HOME}/.docker_auto.env ${_options}"
fi
#
# run it
#

if [ $_auto -eq 0 ] ; then
  docker run $_options -h $_hostname -i -t $_VOLUMES $_CONTAINER bash
else
  echo "looking for last docker session"
  SESSION_NAME=docker_${_auto_name}
  [[ "${_auto_name}" = "auto" ]] && SESSION_NAME=docker_session
  [[ $_clear = 1 ]] && [[ -f ${RUNTIME_HOME}/.$SESSION_NAME ]] && rm -f ${RUNTIME_HOME}/.$SESSION_NAME

  if [ -f ${RUNTIME_HOME}/.$SESSION_NAME ] ; then
    _session=$(cat ${RUNTIME_HOME}/.$SESSION_NAME)
  else
    _session=$(docker run $_options -d -h $_hostname -i -t $_VOLUMES $_CONTAINER bash )
  fi
  echo -n $_session > ${RUNTIME_HOME}/.$SESSION_NAME
  echo "checking if $_session running"
  docker ps |grep $(echo $_session|cut -c1-12)
  if [ ! $? -eq 0 ]; then
    echo "starting docker session"
    docker start $_session
  fi
  echo "attaching to docker"
  docker attach $_session
fi
