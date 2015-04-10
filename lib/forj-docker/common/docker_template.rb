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
  require 'lorj'
  require 'forj-docker/common/erb_data'
  require 'forj-docker/common/helpers'
rescue LoadError
  require 'rubygems'
  require 'erb'
  require 'lorj'
  require 'forj-docker/common/erb_data'
  require 'forj-docker/common/helpers'
end
include Helpers
#
# class for managing Dockerfiles
# features include:
# - process dockerfiles with erb templates
# - get a default docker_workarea directory
# - default Dockerfile meta data properties
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
      :expose_ports     => '22 80 443',
      :file_name        => nil
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
      PrcLib.error('failed to process dockerfile for %s : %s',
                   vals[:node], e.message)
    end
  end

  #
  # get the default workarea, current directory + docker
  #
  def default_workarea
    current_dir = File.expand_path('.')
    workarea = File.join(current_dir, 'docker')
    workarea = nil unless File.exist? workarea
    PrcLib.debug "workarea => #{workarea}"
    workarea
  end

  #
  # match token
  def match_token(token, line, options = {})
    options = { :exp => '(.*)',
                :field => 1
             }.merge options
    meta_token = Regexp.new("#{token}\s#{options[:exp]}")
    return line.match(meta_token)[options[:field]] if line.match(meta_token)
    nil
  end

  #
  # get metadata from dockerfile
  #
  def dockerfile_metadata(file = nil)
    meta_data = @properties.merge(:repo_name  => nil,
                                  :image_name => nil,
                                  :file_name  => nil,
                                  :VERSION    => nil,
                                  :maintainer_name  => nil,
                                  :maintainer_email => nil)
    return meta_data unless File.exist?(file)
    meta_data[:file_name] = File.expand_path(file)
    File.open(file, 'r').each do |line|
      [{ :property => :VERSION,         :token => '.*#\sDOCKER-VERSION' },
       { :property => :maintainer_name, :token => '^MAINTAINER',
         :exp => '(.*),\s(.*)', :field => 1 },
       { :property => :maintainer_email, :token => '^MAINTAINER',
         :exp => '(.*),\s(.*)', :field => 2 },
       { :property => :image_name,      :token => '.*#\sDOCKER-NAME',
         :exp => '(.*)/(.*)', :field => 2 },
       { :property => :repo_name,  :token => '.*#\sDOCKER-NAME' }].each do |p|
        match_val = match_token(p[:token], line, p)
        meta_data[p[:property]] = match_val unless match_val.nil?
      end
    end
    meta_data
  end
end
