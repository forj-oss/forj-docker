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

module ForjDocker
  # Common settings
  module Settings
    # Defines common thor settings (debug/verbose)

    def self.common_options(options)
      PrcLib.level = Logger::INFO if options[:verbose]
      PrcLib.level = Logger::DEBUG if options[:debug]
      unless options[:libforj_debug].nil?
        PrcLib.core_level = options[:libforj_debug].to_i
        PrcLib.level = Logger::DEBUG
      end
      PrcLib.debug("current options => #{options}")
    end

    # configuration set
    def self.config_set(conf, *p)
      b_dirty = false

      p.flatten!
      p.each do |key_val|
        key_to_set, key_value = key_match(key_val)
        PrcLib.message("#{key_to_set} #{key_value}")
        unless config_setting_exist?(conf, key_to_set)
          PrcLib.warning("key '%s' configuration does not exist." \
                         '  Check command settings. ',
                         key_to_set)
        end

        # We assume no runtime has been set before.
        bef = _data_state(conf, key_to_set)
        config_set_local(conf, key_to_set, key_value)
        aft = _data_state(conf, key_to_set)

        if bef == aft
          PrcLib.message '%-15s: No update', key_to_set.to_s
          next
        end
        b_dirty = true
        PrcLib.message '%s: %s => %s', key_to_set, bef, ANSI.bold(aft)
      end
      conf.save_local_config if b_dirty
    end

    # State the current key value.
    def self._data_state(conf, key_to_set)
      where = conf.where?(key_to_set)
      if where
        format("'%s' (%s)", conf[key_to_set], where[0])
      else
        'no value'
      end
    end

    # local set
    def self.config_set_local(conf, key, value)
      key = key.to_sym if key.class == String
      if value != ''
        conf.local_set(key, value)
      else
        conf.local_del(key)
      end
      conf
    end

    # key match
    def self.key_match(key_val)
      mkey_val = key_val.match(/^(.*) *= *(.*)$/)

      PrcLib.fatal(1, 'Syntax error. Please set your value like:' \
                      " 'key=value' and retry.") unless mkey_val

      key_to_set = mkey_val[1]
      key_value  = mkey_val[2]

      key_to_set = key_to_set.to_sym if key_to_set.class == String

      [key_to_set, key_value]
    end

    # show all settigns
    def self.config_show_all(conf)
      PrcLib.message 'List of available forj-docker default settings:'
      PrcLib.message "%-15s %-12s :\n------------------------------",
                     'section name', 'key'
      conf.meta_each do |section, found_key, hValue|
        next if hValue.rh_get(:readonly)
        description = hValue.rh_get(:desc)
        PrcLib.message '%-15s %-12s : %s', section, found_key, description
      end
      PrcLib.message "\nUse `forj-docker configure" \
        ' key=value` to set one. '
    end

    # get default value
    # TODO: @chrisssss when we don't know section,
    #       how can we find the default value?
    # chrissss: Use
    # @conf.get(key, :name => 'default')
    def self.get_default(conf, find_section, find_key)
      find_section = find_section.to_sym if find_section.class == String
      find_key     = find_key.to_sym     if find_key.class == String
      conf.meta_each do |section, key, hValue|
        next unless section == find_section
        next unless key == find_key
        return hValue.rh_get(:default_value)
      end

      nil
    end

    # predefined application key exist?
    def self.config_setting_exist?(conf, find_key)
      !conf.get_section(find_key).nil?
    end
  end
end
