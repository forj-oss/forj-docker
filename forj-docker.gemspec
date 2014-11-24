# -*- encoding: utf-8 -*-
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
$:.push File.expand_path(File.join("..","lib"), __FILE__)
require 'rbconfig'
ruby_conf = defined?(RbConfig) ? RbConfig::CONFIG : Config::CONFIG
less_than_one_nine = ruby_conf['MAJOR'].to_i == 1 && ruby_conf['MINOR'].to_i < 9

Gem::Specification.new do |s|
  s.name        = "forj-docker"
  s.version     = `cat VERSION`
  s.authors     = ["forj team"]
  s.email       = %w(forj@forj.io)
  s.homepage    = "https://github.com/forj-oss/forj-docker"
  s.summary     = %q{Gem plugin for forj-cli to work with docker}
  s.description = %q{Gem plugin for forj-cli to work with docker}
  s.license     = 'Apache License, Version 2.0.'
  s.post_install_message = 'Go to docs.forj.io for more information on how to use forj cli'
  s.required_ruby_version = '>= 1.8.5'


  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
#  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Testing dependencies
  s.add_development_dependency 'minitest', '~> 4.0'
  s.add_development_dependency 'fakefs', '0.4'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'simplecov' unless less_than_one_nine

  # Documentation dependencies
  s.add_development_dependency 'yard'
  s.add_development_dependency 'markdown' unless less_than_one_nine
  s.add_development_dependency 'thin'

  # Run time dependencies
  s.add_runtime_dependency 'rake'
#  s.add_runtime_dependency 'rspec'
  s.add_runtime_dependency 'serverspec', '~> 1.0'
  s.add_runtime_dependency 'specinfra', '~> 1.0'
end
