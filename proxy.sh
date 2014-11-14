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
echo "setting up proxy"
export _PROXY=${1:-'http://web-proxy.corp.hp.com:8080'}
if [ ! -z "$_PROXY" ] ; then
    export http_proxy=$_PROXY
    export https_proxy=$http_proxy
    export HTTP_PROXY=$http_proxy
    export HTTPS_PROXY=$http_proxy
    export ftp_proxy=$http_proxy
    export no_proxy=localhost,127.0.0.1,10.0.0.0/16,169.254.169.254
else
    unset http_proxy
    unset https_proxy
    unset HTTP_PROXY
    unset HTTPS_PROXY
    unset ftp_proxy
    unset socks_proxy
    unset no_proxy
    echo "skiping proxy settings"
fi

