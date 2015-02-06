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

def getconfig_spec
  File.expand_path(File.join(getconfig_folder, 'config.yaml'))
end

def getforj_datadir
  if !ENV['FORJ_DATA'].nil? && ENV['FORJ_DATA'] != ''
    ENV['FORJ_DATA']
  else
    File.expand_path(File.join(ENV['HOME'], '.config', 'forj-data'))
  end
end

def getconfig_folder
  config_dir = getforj_datadir
  config_dir = File.expand_path(config_dir)
  FileUtils.mkdir_p(config_dir) unless File.exist?(config_dir)
  config_dir
end

def get_config(property, defaults_hash = {})
  config_file = getconfig_spec
  config = defaults_hash
  if File.exist? config_file
    config = config.merge(YAML.load_file(config_file))
  else
    File.open(config_file, 'w') { |f| f.write config.to_yaml }
  end
  config[property]
end

def write_config(property, value, defaults_hash = {})
  config_file = getconfig_spec
  config = defaults_hash
  config = config.merge(YAML.load_file(config_file)) if File.exist? config_file
  config[property] = value
  File.open(config_file, 'w') { |f| f.write config.to_yaml }
end

def getcurrent_provisioner
  get_config(:provisioner, :provisioner => :vagrant)
end

def setcurrent_provisioner(prov_target)
  write_config(:provisioner, prov_target)
end

#
# setup global debug options
if ENV['FORJ_DOCKER_DEBUG'] != '' && !ENV['FORJ_DOCKER_DEBUG'].nil?
  FORJ_DOCKER_DEBUG = true
else
  FORJ_DOCKER_DEBUG = false
end

#
# setup global docker work area options
PROVISIONER = getcurrent_provisioner
if ENV['DOCKER_WORKAREA'] != '' && !ENV['DOCKER_WORKAREA'].nil?
  DOCKER_WORKAREA = ENV['DOCKER_WORKAREA']
else
  DOCKER_WORKAREA = File.join(File.expand_path('.'), 'docker')
end
puts "Docker work area => #{DOCKER_WORKAREA}"

#
# setup bin, spec lib paths
FORJ_DOCKER_BIN  = File.expand_path(File.join(File.dirname(__FILE__),
                                              '..',
                                              '..',
                                              '..',
                                              'bin'))
FORJ_DOCKER_SPEC = File.expand_path(File.join(File.dirname(__FILE__),
                                              '..',
                                              '..',
                                              '..',
                                              'spec'))
FORJ_DOCKER_LIB  = File.expand_path(File.join(File.dirname(__FILE__),
                                              '..',
                                              '..',
                                              '..',
                                              'lib'))
$LOAD_PATH << FORJ_DOCKER_LIB
