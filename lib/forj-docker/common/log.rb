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

# create a forj.log file in ~/.hpcloud/forj.log

require 'logger'
require 'ansi'
require 'ansi/logger'

require 'common/helpers.rb'
include Helpers

#
# Logging module
#
module Logging
  #
  # Forj logging helper
  #
  class ForjLog
    # Class used to create 2 log object,
    # in order to keep track of error in a log
    # file and change log output to OUTPUT on needs (option flags).

    attr_reader :level

    def initialize(sLogFile = 'forj.log', level = Logger::WARN)
      unless $FORJ_DATA_PATH
        fail 'Internal Error: Unable to initialize ForjLog
               - global FORJ_DATA_PATH not set'
      end

      unless Helpers.dir_exists?($FORJ_DATA_PATH)
        fail format('Internal Error: Unable to ' + \
                    "initialize ForjLog - '%s' doesn't exist.", $FORJ_DATA_PATH)
      end

      @file_logger = Logger.new(File.join($FORJ_DATA_PATH, sLogFile), 'weekly')
      @file_logger.level = Logger::DEBUG
      @file_logger.formatter = proc do |severity, datetime, progname, msg|
        "#{progname} : #{datetime}: #{severity}: #{msg} \n"
      end

      @stdout_logger = Logger.new(STDOUT)
      @level = level
      @stdout_logger.level = @level
      @stdout_logger.formatter = proc do |severity, _datetime, _progname, msg|
        case severity
        when 'ANY'
          str = "#{msg} \n"
        when 'ERROR', 'FATAL'
          str = ANSI.bold(ANSI.red("#{severity}!!!")) + ": #{msg} \n"
        when 'WARN'
          str = ANSI.bold(ANSI.yellow('WARNING')) + ": #{msg} \n"
        else
          str = "#{severity}: #{msg} \n"
        end
        str
      end
    end

    def info?
      @stdout_logger.info?
    end

    def debug?
      @stdout_logger.debug?
    end

    def error?
      @stdout_logger.error?
    end

    def fatal?
      @stdout_logger.fatal?
    end

    def info(message)
      @stdout_logger.info(message + ANSI.clear_line)
      @file_logger.info(message)
    end

    def debug(message)
      @stdout_logger.debug(message + ANSI.clear_line)
      @file_logger.debug(message)
    end

    def error(message)
      @stdout_logger.error(message + ANSI.clear_line)
      @file_logger.error(message)
    end

    def fatal(message, e)
      @stdout_logger.fatal(message + ANSI.clear_line)
      return @file_logger.fatal(message) unless e
      err_message = format("%s\n%s\n%s",
                           message,
                           e.message,
                           e.backtrace.join('\n'))
      @file_logger.fatal(err_message)
    end

    def warn(message)
      @stdout_logger.warn(message + ANSI.clear_line)
      @file_logger.warn(message)
    end

    def setlevel(level)
      @level = level
      @stdout_logger.level = level
    end

    def unknown(message)
      @stdout_logger.unknown(message + ANSI.clear_line)
    end
  end

  def message(message)
    $FORJ_LOGGER.unknown(message)
  end

  def info(message)
    $FORJ_LOGGER.info(message)
  end

  def debug(message)
    $FORJ_LOGGER.debug(message)
  end

  def warning(message)
    $FORJ_LOGGER.warn(message)
  end

  def error(message)
    $FORJ_LOGGER.error(message)
  end

  def fatal(rc, message, e = nil)
    $FORJ_LOGGER.fatal(message, e)
    puts 'Issues found. Please fix it and retry. Process aborted.'
    exit rc
  end

  def setlevel(level)
    $FORJ_LOGGER.setlevel(level)
  end

  def state(message)
    return unless $FORJ_LOGGER.level <= Logger::INFO
    state_message = format("%s ...%s\r", message, ANSI.clear_line)
    print(state_message)
  end

  def high_level_msg(message)
    # Not DEBUG and not INFO. Just printed to the output.
    return unless $FORJ_LOGGER.level > 1
    print(format('%s', message))
  end
end
