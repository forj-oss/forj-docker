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
  name: check_inspect_error_result

  inputs:
    - inspect_error_result

  action:
    python_script: |
      try:
        import os
        return_code = '0'
        return_result = ''
        expected = True
        if "No such image or container: registry2" not in inspect_error_result:
          expected = False
      except:
        return_code = '1'
        return_result = 'Runtime error.'
  results:
    - EXPECTED: expected
    - UNEXPECTED
