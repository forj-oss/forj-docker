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
  name: ssh_check_registry_container_running
  inputs:
    - host
    - port:
        default: "'22'"
    - username
    - privateKeyFile
    - command:
        default: "'docker inspect registry2 | egrep .*Running.*true'"
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
    - inspect_result: returnResult
    - error_message: "'' if 'STDERR' not in locals() else STDERR"
  results:
    - MATCHED : returnCode == '0' and (not 'Error' in STDERR)
    - ERROR_RESULT
