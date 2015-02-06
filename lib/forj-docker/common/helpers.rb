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

# Helper functions for common file system operations.
#
# *Overview*
# Lets make it easy in this project to deal with File things.
# This module is intended to be included at a high level with :
#   include Helpers
#
# Use it in test or gem for normal file operations.
#
module Helpers
  # Get a users home directory of the current process
  #
  def gethome_path
    home_dir = File.expand_path('~')
    if home_dir == '' || home_dir.nil?
      home_dir = (ENV['HOME'] != '' && !ENV['HOME'].nil?) ? ENV['HOME'] : '.'
      home_dir = File.expand_path(home_dir)
    end
    home_dir
  end

  # Create a directory at a given path
  #
  # *Arguments*
  # - path  - Folder to create
  #
  def create_directory(path)
    FileUtils.mkdir_p(path) unless File.exist?(path)
  end

  # Check if a given directory exist and make sure it's writable.
  # Fail the process when thats not true.
  #
  # *Arguments*
  # - path  - Folder to check
  #
  def dir_exists?(path)
    return false unless File.exist?(path)
    validate_directory(path)
    return true unless !File.readable?(path) ||
                       !File.writable?(path) ||
                       !File.executable?(path)
    msg = format('%s is not a valid directory.' \
                 ' Check permissions and fix it.', path)
    PrcLib.fatal(1, msg)
    true
  end

  # Check if a directory exist and use the logging library to
  # report otherwise if it doesn't.  Fail the process.
  #
  # *Arguments*
  # - path  - A folder to validate.
  #
  def validate_directory(path)
    return if File.directory?(path)
    msg = format("'%s' is not a directory. Please fix it.", path)
    PrcLib.fatal(1, msg)
    fail msg
  end

  # Validate that the file exist and fail if it doesn't.
  # Use the current logger to report any issues.
  #
  # *Arguments*
  # - fspec - name of the file to check
  # - msg   - an alternative error message to present.
  #
  def validate_file_andfail(fspec, msg = nil)
    return if File.exist?(fspec)
    msg = format("'%s' does not exist. Please correct.", fspec) if msg.nil?
    PrcLib.fatal(1, msg)
    fail msg
  end

  # Validate that a file exist and warn when it's not.  Don't
  # fail the process.
  #
  # *Arguments*
  # - fspec - name of the file to check
  # - msg   - an alternative error message to present.
  #
  def validate_file_andwarn(fspec, msg = nil)
    return if File.exist?(fspec)
    msg = format("'%s' does not exist.", fspec) if msg.nil?
    PrcLib.warning(msg)
  end

  # Validate that no file exist and warn when it does exist.  Don't
  # fail the process.
  #
  # *Arguments*
  # - fspec - name of the file to check
  # - msg   - an alternative error message to present.
  #
  def validate_nofile_andwarn(fspec, msg = nil)
    return unless File.exist?(fspec)
    msg = format("'%s' already exist.", fspec) if msg.nil?
    PrcLib.warning(msg)
  end

  # Check if a directory exist, when it doesn't create the directory.
  #
  # *Arguments*
  # - path - name of the folder to check
  #
  def ensure_dir_exists(path)
    return if dir_exists?(path)
    FileUtils.mkpath(path) unless File.directory?(path)
  end

  # Create a file from a string
  #
  # *Arguments*
  # - vals  - A string for the contents of the file.
  # - fspec - the name of the file.
  #
  def create_file(contents = '', fspec = nil)
    PrcLib.debug('create file -> %s', fspec)
    return if fspec.nil?
    begin
      File.open(fspec, 'w') do |fw|
        fw.write contents
        fw.close
      end
    rescue StandardError => e
      PrcLib.warning('issues with creating file %s : %s', fspec, e.message)
    end
  end

  # remove a file
  #
  # *Arguments*
  # - fspec - name of the file to remove
  def remove_file(fspec = nil)
    PrcLib.debug('remove file -> %s', fspec)
    return if fspec.nil?
    File.delete(fspec) if File.exist?(fspec)
  end

  # use a regular expression to find files
  #
  def find_files(regex, root_dir = File.expand_path('.'),
                 options = { :recursive => true })
    folders = []
    if options[:recursive]
      folders = Dir.glob(File.join(root_dir, '**', '*'))
                .select { |f| !File.directory? f }
                .select { |f| !regex.match(f).nil? }
    else
      folders = Dir.entries(root_dir)
                .select { |f| !File.directory? f }
                .select { |f| !regex.match(f).nil? }
    end
    folders
  end

  # filter list of files and exclude in return array
  #
  def filter_files(exclude_regex, file_list)
    new_list = []
    file_list.each do |f|
      PrcLib.debug "f => #{f}"
      new_list << f unless exclude_regex.match(f)
    end
    new_list
  end
end
