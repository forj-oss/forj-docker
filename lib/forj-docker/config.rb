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

#
# configure provisioners, to give us the option for creating docker
# image on as many host targets as possible, we are enabling the
# normal build task to be possible to execute on vagrant or bare systems.
#

def get_current_provisioner
  temp_dir = File.join(File.dirname(__FILE__),"tmp")
  Dir.mkdir(temp_dir) unless File.exist?(temp_dir)
  config_file = File.join(temp_dir,"config.yaml")
  config = {:provisioner => :vagrant}
  if File.exist? config_file
    config = config.merge(YAML::load_file(config_file))
  else
    File.open(config_file, 'w') {|f| f.write config.to_yaml }
  end
  return config[:provisioner]
end

def set_current_provisioner(prov_target)
  temp_dir = File.join(File.dirname(__FILE__),"tmp")
  Dir.mkdir(temp_dir) unless Dir.exist?(temp_dir)
  config_file = File.join(temp_dir,"config.yaml")
  config = {}
  if File.exist? config_file
    config = config.merge(YAML::load_file(config_file))
  end
  config[:provisioner] = prov_target
  File.open(config_file, 'w') {|f| f.write config.to_yaml }
end

PROVISIONER = get_current_provisioner
DOCKER_WORKAREA = (ENV['DOCKER_WORKAREA'] != '' and ENV['DOCKER_WORKAREA'] != nil) ? ENV['DOCKER_WORKAREA'] : 'docker'
FORJ_DOCKER_BIN = File.join(File.dirname(__FILE__),"..","..","bin")
