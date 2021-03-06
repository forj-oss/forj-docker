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

#
# Helper functions
#

::Hash.class_eval do
  def sym_keys
    s2s =
          lambda do |h|
            if h.is_a?(Hash)
              Hash[h.map do |k, v|
                [k.respond_to?(:to_sym) ? k.to_sym : k, s2s[v]]
              end]
            else
              h
            end
          end
    s2s[self]
  end
end
