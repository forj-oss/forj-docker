#!/usr/bin/env ruby
# encoding: UTF-8

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
# spec defaults
module CliSpec
  # spec defaults
  module InitDefaults
    def spec_init_files_empty
      files = []
      files << 'spec/fixtures/init_empty/Rakefile'
      files << 'spec/fixtures/init_empty/README.md'
      files << 'spec/fixtures/init_empty/docker/review/.gitignore'
      files << 'spec/fixtures/init_empty/docker/review/Dockerfile.review'
      files << 'spec/fixtures/init_empty/docker/review/runit.sh'
      files << 'spec/fixtures/init_empty/docker/review/setup_sources.sh'
      files
    end

    def forj_script
      @forj_script = <<-EOS
      require 'forj-docker'
      ForjDocker::Cli::ForjDockerThor.start
      EOS
      @forj_script
    end

    def spec_bp_name
      'test_bp'
    end

    # a sample layout file
    def layout_contents
      @layout = <<-LAYOUT
      blueprint-deploy:
      layout: #{spec_bp_name} # name of the layout file we use
      blueprint : #{spec_bp_name} # name of the default blueprint
      servers:
      - server1:
      name: util
      applications:
      - app1:
      - app2:
      - server2:
      name: review
      applications:
      - app1:
      - app3:
      LAYOUT
      @layout
    end

    # master yaml configuration file.
    def master_contents
      @master = <<-MASTER
      blueprint:
      name: #{spec_bp_name}
      description: This is for testing purposes
      icon:
      file : test.png
      content : (--- base64 encoded ---)
      documentation : 'http://openstack.org/forj'
      locations:
      modules:
      - src-repo: redstone
      git: https://review.forj.io/p/forj-oss/redstone
      puppet-apply: install
      - src-repo: config
      git: https://review.forj.io/p/oo-infra/config
      puppet-extra-modules: /opt/config/production/git/config/modules
      MASTER
      @master
    end
  end
end