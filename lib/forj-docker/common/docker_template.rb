#!/usr/bin/env ruby
# encoding: UTF-8

# (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

begin
  require 'erb'
  require 'forj-docker/common/erb_data'
  require 'forj-docker/common/log'
rescue LoadError
  require 'rubygems'
  require 'erb'
  require 'forj-docker/common/erb_data'
  require 'forj-docker/common/log'
end
include Logging
#
# class for managing Dockerfiles with erb templates
#
class DockerTemplate
  attr_accessor :properties
  def initialize(def_properties = {})
    @properties = {
      :VERSION          => '0.0.1',
      :repo_name        => 'norepo',
      :blueprint_name   => 'none',
      :node             => 'default',
      :maintainer_name  => 'your name',
      :maintainer_email => 'youremail@yourdomain.com',
      :base_image       => 'forj/ubuntu:precise',
      :workspace_dir    => '/opt/workspace',
      :expose_ports     => '22 80 443'
    }.merge(def_properties)
  end

  #
  # process docker file erb
  #
  def process_dockerfile(fdocker_erb, fdocker_dest, vals = {})
    vals = @properties.merge(vals)
    erb = ERB.new(File.read(fdocker_erb))
    erb.def_method(ErbData, 'render', fdocker_erb)
    begin
      File.open(fdocker_dest, 'w') do |fw|
        fw.write ErbData.new(vals).render
        fw.close
      end
    rescue StandardError => e
      Logging.error(format('failed to process dockerfile for %s : %s',
                           vals[:node], e.message))
    end
  end
end
