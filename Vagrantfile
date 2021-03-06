# -*- mode: ruby -*-
# vi: set ft=ruby :
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

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu/trusty64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  # config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
     # Use VBoxManage to customize the VM. For example to change memory:
     vb.customize ["modifyvm", :id, "--memory", "1024"]
  end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

  # Enable provisioning with CFEngine. CFEngine Community packages are
  # automatically installed. For example, configure the host as a
  # policy server and optionally a policy file to run:
  #
  # config.vm.provision "cfengine" do |cf|
  #   cf.am_policy_hub = true
  #   # cf.run_file = "motd.cf"
  # end
  #
  # You can also configure and bootstrap a client to an existing
  # policy server:
  #
  # config.vm.provision "cfengine" do |cf|
  #   cf.policy_server_address = "10.0.2.15"
  # end

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  # You will need to create the manifests directory and a manifest in
  # the file default.pp in the manifests_path directory.
  #
  # config.vm.provision "puppet" do |puppet|
  #   puppet.manifests_path = "manifests"
  #   puppet.manifest_file  = "default.pp"
  # end

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  #
  # config.vm.provision "chef_solo" do |chef|
  #   chef.cookbooks_path = "../my-recipes/cookbooks"
  #   chef.roles_path = "../my-recipes/roles"
  #   chef.data_bags_path = "../my-recipes/data_bags"
  #   chef.add_recipe "mysql"
  #   chef.add_role "web"
  #
  #   # You may also specify custom JSON attributes:
  #   chef.json = { mysql_password: "foo" }
  # end

  # Enable provisioning with chef server, specifying the chef server URL,
  # and the path to the validation key (relative to this Vagrantfile).
  #
  # The Opscode Platform uses HTTPS. Substitute your organization for
  # ORGNAME in the URL and validation key.
  #
  # If you have your own Chef Server, use the appropriate URL, which may be
  # HTTP instead of HTTPS depending on your configuration. Also change the
  # validation key to validation.pem.
  #
  # config.vm.provision "chef_client" do |chef|
  #   chef.chef_server_url = "https://api.opscode.com/organizations/ORGNAME"
  #   chef.validation_key_path = "ORGNAME-validator.pem"
  # end
  #
  # If you're using the Opscode platform, your validator client is
  # ORGNAME-validator, replacing ORGNAME with your organization name.
  #
  # If you have your own Chef Server, the default validation client name is
  # chef-validator, unless you changed the configuration.
  #
  #   chef.validation_client_name = "ORGNAME-validator"
  #
  ###
  # lets only setup proxies when our local ip is 15.255.x.x
  # we might change this later to not be hardcoded.
  DEBUG=( ENV['DEBUG'] != '' and ENV['DEBUG'] != nil ) ? ENV['DEBUG'] : ''
  if ENV['http_proxy'] != '' and ENV['http_proxy'] != nil then
    http_proxy= ENV['http_proxy']
    proxy_cmd = "[ -e /vagrant/bin/scripts/proxy.sh ] && echo 'export PROXY=\"#{http_proxy}\"' > /etc/profile.d/proxy_00.sh"
    proxyln_cmd = "[ -e /vagrant/bin/scripts/proxy.sh ] && cp /vagrant/bin/scripts/proxy.sh /etc/profile.d/proxy_01.sh"
    proxychmod_cmd = "[ -e /vagrant/bin/scripts/proxy.sh ] && chmod a+x /etc/profile.d/proxy_??.sh"
    proxyexec_cmd = "[ -e /etc/profile.d/proxy_00.sh ] && . /etc/profile.d/proxy_00.sh && . /etc/profile.d/proxy_01.sh"
  else
    proxyexec_cmd = "[ -f /etc/profile.d/proxy.sh ] && rm -f /etc/profile.d/proxy_??.sh"
  end

  ###
  $script = <<SCRIPT
  #
  # grant current user access to docker
  #
  [ "$DEBUG" = "1" ] && set -x -v
  echo I am provisioning...
  mkdir -p /vagrant/tmp
  date > /vagrant/tmp/vagrant_provisioned_at
  echo 'running command: #{proxy_cmd}'
  #{proxy_cmd}
  #{proxyln_cmd}
  #{proxychmod_cmd}
  #{proxyexec_cmd}
  apt-get update
  apt-get -y install git curl wget
  bash /vagrant/bin/scripts/docker_install.sh vagrant
SCRIPT

   config.vm.provision "shell", inline: $script

  $script_gem = <<SCRIPT_GEM
  sudo apt-get install ruby1.9.1            \
  ruby1.9.1-dev        \
  rubygems1.9.1        \
  build-essential      \
  libopenssl-ruby1.9.1 \
  libssl-dev           \
  zlib1g-dev           \
  libxml2-dev          \
  libxslt-dev          \
  ncurses-dev          \
  git -y
  sudo -E gem1.9.1 install bundler --no-rdoc --no-ri
  cd /vagrant
  ruby1.9.1 -S bundle install --gemfile Gemfile
SCRIPT_GEM
   config.vm.provision "shell", inline: $script_gem
end
