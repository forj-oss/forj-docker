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
  require 'yaml'
  require 'lorj'
rescue LoadError
  require 'rubygems'
  require 'yaml'
  require 'lorj'
end

# Evaluate a blueprint folder and load it's properties.
#
# *Overview*
#
# This class will be used to mock data being read from forj
# blueprints.  When found we will read a name-master.yaml and
# name-layout.yaml.  This will only occur if name (the bluerpint name)
# is provided.  Otherwise only properties that are defaulted will be
# found.
#
# *Example*
#
#    bp = Blueprint.new :name => 'myblueprint'
#    puts bp.properties[:name] # will print myblueprint
#
# *TODO*
# * implement reading blueprints
# * implement reading meta_data
# * evaluate integration with lorj
#
class Blueprint # rubocop:disable ClassLength
  attr_accessor :properties

  def initialize(def_properties = {})
    @properties = {
      :name             => 'undef',
      :blueprint_name   => 'undef',
      :layout_name      => 'undef',
      :version          => '0.0.0',
      :nodes            => 'undef',
      :work_dir         => File.join(File.expand_path('.'), 'forj'),
      :maintainer_name  => 'your name',
      :maintainer_email => 'youremail@yourdomain.com',
      :expose_ports     => '22 80 443',
      :layout_file      => 'undef',
      :master_file      => 'undef'
    }.merge(def_properties)
    # default we should use blueprint name when layout is not set
    (@properties[:layout_name] == 'undef' && @properties[:name] != 'undef') &&
      @properties[:layout_name] = @properties[:name]

    (@properties[:name] != 'undef') &&
      @properties[:blueprint_name] = @properties[:name]
  end

  # setup blueprint properties
  def setup(layout_name = @properties[:layout_name])
    if layout_name == 'undef'
      layout_name = findfirst_blueprint_name
      @properties[:layout_name] = layout_name
    end
    find_blueprint_config layout_name unless layout_name == 'undef'
    find_blueprint_nodes layout_name unless layout_name == 'undef'
  end

  # Find blueprint name from layout
  #
  # *Overviwe*
  #
  # Determines the blueprint name from a given layout file.
  # This can be used to locate the blueprint-master.yaml file.
  #
  def blueprint_from_layout(layout_file)
    return 'undef' unless File.exist?(layout_file)
    blueprint = YAML.load_file(File.expand_path(layout_file))
    begin
      return blueprint['blueprint-deploy']['blueprint']
    rescue StandardError => e
      PrcLib.error('failed to get blueprint from %s : %s',
                   layout_file, e.message)
    end
  end

  # Set blueprint core properties
  #
  # *Overview*
  #
  # Setup any core properties for the blueprint class such as layout_name
  # and name of the blueprint.
  #
  def setcore_properties(layout_file = nil, layout_name = nil)
    return if layout_file.nil?  ||
              layout_file == '' ||
              !(File.exist? layout_file)

    return if layout_name.nil?  ||
              layout_name == ''

    @properties[:layout_name]    = layout_name
    @properties[:name]           = blueprint_from_layout layout_file
    @properties[:blueprint_name] = @properties[:name]
  end

  # Find blueprint nodes
  #
  # *Overview*
  #
  # Populate properties[:nodes] with valid list of names from blueprint layout.
  # This method will require for the core properties to be set first.
  #
  def find_blueprint_nodes(layout_name = @properties[:layout_name])
    PrcLib.debug('working on finding nodes for %s', layout_name)
    nodes = []
    search_dir = File.expand_path(@properties[:work_dir])
    return if layout_name == 'undef' || !(dir_exists? search_dir)
    find_blueprint_config layout_name

    return if @properties[:layout_file] == 'undef'
    blueprint = YAML.load_file(@properties[:layout_file])
    begin
      nodes << blueprint['blueprint-deploy']['servers'].map { |n| n['name'] }
    rescue StandardError => e
      PrcLib.error('failed to process dockerfile for %s : %s', nodes, e.message)
    end
    @properties[:nodes] = nodes.flatten.uniq
  end

  # Validate blueprint configuration
  #
  def validate_blueprint_config(layout_name = 'undef', search_dir)
    if layout_name == 'undef' || !(dir_exists? search_dir)
      PrcLib.error("Blueprint folder #{search_dir} not found!")
      return false
    end
    unless find_files(/#{layout_name}-layout.yaml/, search_dir,
                      :recursive => false).length > 0
      PrcLib.warning("Missing layout for blueprint in #{search_dir}")
      return false
    end
    true
  end

  # Find blueprint files
  #
  # *Overview*
  #
  # Use @properties[:workd_dir] to search for blueprint configuration
  # files.  This method will configure @properties[:layout_file]
  # and @properties[:master_file].
  #
  # *Arguments*
  # * layout_name - optional name to search for a layout file.
  #
  def find_blueprint_config(layout_name = @properties[:layout_name])
    search_dir = File.expand_path(@properties[:work_dir])
    return unless validate_blueprint_config layout_name, search_dir

    # first find the layout file that will be used to build with.
    # This is considered the default deploy file.
    layout_file_arr = find_files(/#{layout_name}-layout.yaml/, search_dir,
                                 :recursive => false)
    # setup the core_properties needed to find
    @properties[:layout_file] = File.join(@properties[:work_dir],
                                          layout_file_arr[0])
    setcore_properties @properties[:layout_file], layout_name

    # use the layout file to find the master
    master_file_arr = find_files(/#{@properties[:name]}-master.yaml/,
                                 search_dir,
                                 :recursive => false)
    unless master_file_arr.length > 0
      PrcLib.warning("Missing layout for blueprint in #{search_dir}")
      return
    end
    @properties[:master_file] = File.join(@properties[:work_dir],
                                          master_file_arr[0])
  end

  # find first blueprint name available
  #
  # *Overview*
  #
  # If no layout is specified, then use this function to find the first
  # occuring match of a layout and master file, use the blueprint_name
  # as a result.
  #
  def findfirst_blueprint_name
    return 'undef' unless File.directory?(@properties[:work_dir])
    layout_files = Dir.entries(File.join(@properties[:work_dir]))
                   .select { |f| !File.directory? f }
                   .select { |f| f =~ /.*-layout.yaml/ }
    layout_files.each do |layout_file|
      layout_path = File.expand_path(File.join(@properties[:work_dir],
                                               layout_file))
      layout_name = blueprint_from_layout layout_path
      master_path = File.expand_path(File.join(@properties[:work_dir],
                                               "#{layout_name}-master.yaml"))
      return layout_name if File.exist?(master_path)
    end
    'undef'
  end

  # check to see if we have a blueprint config file
  #
  # *Overview*
  #
  # validate that the work_dir has a set of blueprint files.
  #
  def exist_blueprint?
    PrcLib.debug("checking for blueprints '%s'", @properties[:work_dir])
    return false unless File.directory?(@properties[:work_dir])
    (findfirst_blueprint_name != 'undef')
  end
end
