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
require 'yaml'

def get_configspec()
  return File.expand_path(File.join(get_configfolder,"config.yaml"))
end

def get_forjdatadir
  root_data = (ENV['FORJ_DATA'] != nil and ENV['FORJ_DATA'] != '') ? ENV['FORJ_DATA']:
              File.expand_path(File.join(ENV['HOME'],".config","forj-data"))
  return root_data
end

def get_configfolder()
  config_dir = get_forjdatadir
  config_dir = File.expand_path(config_dir)
  Dir.mkdir(config_dir) unless File.directory?(config_dir)
  return  config_dir
end

def get_config(property, defaults_hash = {})
  config_file = get_configspec
  config = defaults_hash
  if File.exist? config_file
    config = config.merge(YAML::load_file(config_file))
  else
    File.open(config_file, 'w') {|f| f.write config.to_yaml }
  end
  return config[property]
end

def write_config(property, value, defaults_hash = {})
  config_file = get_configspec
  config = defaults_hash
  if File.exist? config_file
    config = config.merge(YAML::load_file(config_file))
  end
  config[property] = value
  File.open(config_file, 'w') {|f| f.write config.to_yaml }
end

def get_current_provisioner
  return get_config(:provisioner,  {:provisioner => :vagrant})
end

def set_current_provisioner(prov_target)
  write_config(:provisioner, prov_target)
end

PROVISIONER = get_current_provisioner
DOCKER_WORKAREA  = (ENV['DOCKER_WORKAREA'] != '' and ENV['DOCKER_WORKAREA'] != nil) ?
                      ENV['DOCKER_WORKAREA'] :
                      File.join(File.expand_path('.'),'docker')
puts "Docker work area => #{DOCKER_WORKAREA}"
FORJ_DOCKER_BIN  = File.expand_path(File.join(File.dirname(__FILE__),"..","..","..","bin"))
FORJ_DOCKER_SPEC = File.expand_path(File.join(File.dirname(__FILE__),"..","..","..","spec"))
