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

namespace: cloudslang-docker.ssh-docker-host

operation:
  name: ssh_docker_run_registry_container
  inputs:
    - host
    - port:
        default: "'22'"
    - username
    - privateKeyFile
    - hostPort:
        default: "'80'"
    - base_storage_path:
        default: "'/opt/docker_registry/data'"
    - local_storage_path:
        default: "'$(pwd)/docker_registry/data'"
    - http_proxy:
        default: "''"
    - https_proxy:
        default: "''"
    - command:
        default: "'docker run -d -p ' + hostPort + ':5000'+  ' -v ' + local_storage_path + ':' + base_storage_path + ' -e STORAGE_PATH=' + base_storage_path + ' -e SEARCH_BACKEND=sqlalchemy -e http_proxy=' + http_proxy + ' -e https_proxy=' + https_proxy + ' -e HTTP_PROXY=' + http_proxy + ' -e HTTPS_PROXY=' + https_proxy + ' --name registry2 registry:2.0'"
        overridable: false
    - arguments:
        default: "''"
    - characterSet:
        default: "'UTF-8'"
    - pty:
        default: "'false'"
    - timeout:
        default: "'30000000'"
    - closeSession:
        default: "'false'"
  action:
    java_action:
      className: org.openscore.content.ssh.actions.SSHShellCommandAction
      methodName: runSshShellCommand
  outputs:
    - db_container_ID: returnResult
    - error_message: "'' if 'STDERR' not in locals() else STDERR if returnCode == '0' else ''"
  results:
    - RUNNING : returnCode == '0' and (not 'Error' in STDERR)
    - ERROR_RESULT
