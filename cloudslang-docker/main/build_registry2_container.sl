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

namespace: cloudslang-docker.main

imports:
  util: cloudslang-docker.util
  ssh_docker: cloudslang-docker.ssh-docker-host

flow:
  name: build_registry2_container

  inputs:
    - host_login_url
    - host_login_username
    - host_login_identity_path
    - host_registry_port
    - registry_container_base_storage_path
    - registry_host_local_storage_path
    - registry_http_proxy:
        required: false
    - registry_https_proxy:
        required: false

  workflow:
    # - test_input_param:
    #     do:
    #       util.print:
    #         - text: "'port:' + host_registry_port + ', base: ' + registry_container_base_storage_path + ', local: ' + registry_host_local_storage_path"
    - check_registry_container_running:
        do:
          ssh_docker.ssh_check_registry_container_running:
            - host: host_login_url
            - username: host_login_username
            - privateKeyFile: host_login_identity_path
            # - argument: "'-q'"
        publish:
            - check_registry_container_running_result: inspect_result
            - check_registry_container_running_error_message: error_message
        navigate:
          ERROR_RESULT: check_whether_error_result_is_expected
          MATCHED: print_check_registry_container_running_matched
    - print_check_registry_container_running_matched:
        do:
          util.print_nav:
            - text: "'Container ''registry2'' is already running.'"
        navigate:
          NAV: print_finish
        # TODO: 1. stop the existing registry container and remove
        #       2. run the new one
    - check_whether_error_result_is_expected:
        do:
          util.check_inspect_error_result:
            - inspect_error_result: check_registry_container_running_error_message
        navigate:
          UNEXPECTED: print_check_registry_running_with_unexpected_error
          EXPECTED: print_registry_about_to_create
    - print_registry_about_to_create:
        do:
          util.print:
            - text: "'No ''registry2'' container is running. Start to run a new one.'"
    - excute_docker_run:
        do:
          ssh_docker.ssh_docker_run_registry_container:
            - host: host_login_url
            - username: host_login_username
            - privateKeyFile: host_login_identity_path
            - hostPort: host_registry_port
            - base_storage_path: registry_container_base_storage_path
            - local_storage_path: registry_host_local_storage_path
            - http_proxy: registry_http_proxy
            - https_proxy: registry_https_proxy
        publish:
            - exec_docker_run_registry_container_result: db_container_ID
            - exec_docker_run_registry_container_error_message: error_message
        navigate:
          ERROR_RESULT: print_docker_run_registry_container_error_result
          RUNNING: print_exec_docker_run_registry_container_result
    - print_exec_docker_run_registry_container_result:
        do:
          util.print_nav:
            - text: "'Container ''registry2'' is running now, ID: ' + exec_docker_run_registry_container_result"
        navigate:
          NAV: print_finish
    - print_docker_run_registry_container_error_result:
        do:
          util.print_nav:
            - text: "'Registry container failed to run, error message:' + exec_docker_run_registry_container_error_message"
        navigate:
          NAV: print_finish
    - print_check_registry_running_with_unexpected_error:
        do:
          util.print:
            - text: "'Unexpected erorr while checking registrying is running:' + check_registry_container_running_error_message"
    - print_finish:
        do:
          util.print:
            - text: "'All the scripts have been executed successfully'"
    # - print_at_last:
    #     do:
    #       util.print:
    #         - text: "'print at last'"
    - on_failure:
      - print_error_message:
          do:
            util.print:
              - text: "'Failure has been detected: ' + check_registry_container_running_error_message"
