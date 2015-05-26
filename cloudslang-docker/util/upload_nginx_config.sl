# Copyright 2015 Hewlett-Packard Development Company, L.P.
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

namespace: cloudslang-docker.util

operation:
  name: upload_nginx_config

  inputs:
    - host
    - username
    - privateKeyFile
    - configsPath

  action:
    python_script: |
      import subprocess
      command = "scp -i "+ privateKeyFile + " -r " + configsPath + " " + username + "@" + host + ":~"
      print "Running command: '" + command + "'"
      exit_code = subprocess.call(command, shell=True)
  results:
    - SUCCESS: exit_code == 0
    - FAILURE