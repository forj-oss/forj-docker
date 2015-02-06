# (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
RELATIVE_ROOT_DIR = File.dirname(__FILE__)
RELATIVE_INC_FOLDER = 'provisioner'
$LOAD_PATH << RELATIVE_ROOT_DIR

# we only look 1 level deep into the provisioner folder
include_folders = Dir.entries(File.join(RELATIVE_ROOT_DIR, RELATIVE_INC_FOLDER))
                  .select { |f| !(f =~ /\.+/) }
                  .map { |f| RELATIVE_INC_FOLDER + '/' + f }

# find all the task.rb files and require them
include_folders.each do |inc_folder|
  Dir.entries(File.join(RELATIVE_ROOT_DIR, inc_folder))
    .select { |f| !File.directory? f }
    .select { |f| f =~ /task.rb/ }
    .select { |f| require inc_folder + '/' + f }
end
