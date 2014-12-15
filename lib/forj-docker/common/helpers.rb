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

require 'fileutils'

#
# Helper functions
#
module Helpers
  def gethome_path
    home_dir = File.expand_path('~')
    if home_dir == '' || home_dir.nil?
      home_dir = (ENV['HOME'] != '' && !ENV['HOME'].nil?) ? ENV['HOME'] : '.'
      home_dir = File.expand_path(home_dir)
    end
    home_dir
  end

  def create_directory(path)
    Dir.mkdir path unless File.directory?(path)
  end

  def dir_exists?(path)
    return false unless File.exist?(path)
    validate_directory(path)
    return true unless !File.readable?(path) ||
                       !File.writable?(path) ||
                       !File.executable?(path)
    msg = format('%s is not a valid directory.' + \
                 ' Check permissions and fix it.', path)
    return msg unless $FORJ_LOGGER
    Logging.fatal(1, msg)
    true
  end

  def validate_directory(path)
    return if File.directory?(path)
    msg = format("'%s' is not a directory. Please fix it.", path)
    Logging.fatal(1, msg) if $FORJ_LOGGER
    fail msg
  end

  def validate_file_andfail(fspec, msg = nil)
    return if File.exist?(fspec)
    msg = format("'%s' does not exist. Please correct.", fspec) if msg.nil?
    Logging.fatal(1, msg) if $FORJ_LOGGER
    fail msg
  end

  def validate_file_andwarn(fspec, msg = nil)
    return if File.exist?(fspec)
    msg = format("'%s' does not exist.", fspec) if msg.nil?
    Logging.warning(msg) if $FORJ_LOGGER
  end

  def validate_nofile_andwarn(fspec, msg = nil)
    return unless File.exist?(fspec)
    msg = format("'%s' already exist.", fspec) if msg.nil?
    Logging.warning(msg) if $FORJ_LOGGER
  end

  def ensure_dir_exists(path)
    return if dir_exists?(path)
    FileUtils.mkpath(path) unless File.directory?(path)
  end
end
