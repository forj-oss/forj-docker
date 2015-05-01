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

source ENV['GEM_SOURCE'] || 'https://rubygems.org'

$LOAD_PATH << File.expand_path(File.join(__FILE__, '..', 'lib'))
require 'rbconfig'
ruby_conf = defined?(RbConfig) ? RbConfig::CONFIG : Config::CONFIG
less_than_one_nine = ruby_conf['MAJOR'].to_i == 1 && ruby_conf['MINOR'].to_i < 9

# setup : bundle install   or bundle update
# serverspec docs: http://serverspec.org/
group :development, :test do
  gem 'debugger',                :require => false unless less_than_one_nine
  gem 'ruby-debug',              :require => false if less_than_one_nine
  gem 'rake',                    :require => false
  gem 'rubocop',                 :require => false
  gem 'rspec-puppet',            :require => false
  gem 'puppetlabs_spec_helper',  :require => false
  gem 'serverspec',              :require => false
  gem 'puppet-lint',             :require => false
  gem 'beaker-rspec',            :require => false
  gem 'puppet_facts',            :require => false
end

gemspec
