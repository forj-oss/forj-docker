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

source ENV['GEM_SOURCE'] || "https://rubygems.org"
# setup : bundle install   or bundle update
group :development, :test do
  gem 'debugger',                :require => false
  gem 'rake',                    :require => false
  gem 'rspec-puppet',            :require => false
  gem 'puppetlabs_spec_helper',  :require => false
  gem 'serverspec',              :require => false
  gem 'puppet-lint',             :require => false
  gem 'beaker-rspec',            :require => false
  gem 'puppet_facts',            :require => false
end

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', '1.7.6', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', '2.7.25', :require => false
end


