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

# Test Blueprint class
#
# *Test*
# * create class with blueprint name
# * find blueprint files given a work_dir

spec_dir = File.join(File.expand_path(File.dirname(__FILE__)), '..')
$LOAD_PATH << spec_dir
require 'spec_helper'
require 'rubygems'

$LOAD_PATH << File.join(spec_dir, '..', 'lib')
require 'forj-docker/common/log'
require 'forj-docker/common/blueprint'

describe 'Blueprint empty class', :default => true do
  before :all do
    @blueprint = Blueprint.new
  end

  it 'should have a undef name' do
    expect(@blueprint.properties[:name]).to eq('undef')
  end
end

describe 'Blueprint class with data', :default => true do
  before :all do
    @spec_work_dir = 'spec/fixtures/forj'
    @spec_bp_name = 'testbp'
    # layout and master spec file
    @layout_file = 'spec/fixtures/forj/testbp-layout.yaml'
    @master_file = 'spec/fixtures/forj/testbp-master.yaml'

    # a sample layout file
    @layout = <<-LAYOUT
blueprint-deploy:
  layout: #{@spec_bp_name} # name of the layout file we use
  blueprint : #{@spec_bp_name} # name of the default blueprint
  servers:
    - server1:
      name: util
      applications:
        - app1:
        - app2:
    - server2:
      name: review
      applications:
        - app1:
        - app3:
LAYOUT

    #
    # master yaml configuration file.
    @master = <<-MASTER
blueprint:
  name: #{@spec_bp_name}
  description: This is for testing purposes
  icon:
    file : test.png
    content : (--- base64 encoded ---)
  documentation : 'http://openstack.org/forj'
  locations:
    modules:
      - src-repo: redstone
        git: https://review.forj.io/p/forj-oss/redstone
        puppet-apply: install
      - src-repo: config
        git: https://review.forj.io/p/oo-infra/config
        puppet-extra-modules: /opt/config/production/git/config/modules
MASTER

    # remove the layout and master file if they exist
    remove_file @layout_file
    remove_file @master_file

    # generate the layout and master file.
    ensure_dir_exists @spec_work_dir
    create_file @layout, @layout_file
    create_file @master, @master_file
  end

  before :each do
    # create a new blueprint object before every test
    @blueprint = Blueprint.new :work_dir => @spec_work_dir
  end

  it 'initialize setting layout from name' do
    @blueprint = Blueprint.new :name => 'under_test'
    expect(@blueprint.properties[:layout_name]).to eq('under_test')
    expect(@blueprint.properties[:name]).to eq('under_test')
  end

  it 'initialize properties values' do
    def_values = {
      :name             => 'under_test',
      :layout_name      => 'layout_under_test',
      :version          => '9999.9999.9999',
      :nodes            => %w(node1 node_under_test),
      :work_dir         => @spec_work_dir,
      :maintainer_name  => 'My TesterName',
      :maintainer_email => 'under_test@domain.com',
      :expose_ports     => '111 222 333',
      :layout_file      => @layout_file,
      :master_file      => @master_file,
      :custom_string    => 'custom_string',
      :custom_bool      => true,
      :custom_int       => 42

    }
    @blueprint = Blueprint.new def_values
    expect(@blueprint.properties[:name]).to eq('under_test')
    expect(@blueprint.properties[:blueprint_name]).to eq('under_test')
    expect(@blueprint.properties[:layout_name]).to eq('layout_under_test')
    expect(@blueprint.properties[:version]).to eq('9999.9999.9999')
    expect(@blueprint.properties[:nodes]).to include 'node_under_test'
    expect(@blueprint.properties[:work_dir])
      .to eq(@spec_work_dir)
    expect(@blueprint.properties[:maintainer_name])
      .to eq('My TesterName')
    expect(@blueprint.properties[:maintainer_email])
      .to eq('under_test@domain.com')
    expect(@blueprint.properties[:expose_ports]).to eq('111 222 333')
    expect(@blueprint.properties[:expose_ports]).not_to eq('22 80 443')
    expect(@blueprint.properties[:layout_file]).to eq(@layout_file)
    expect(@blueprint.properties[:layout_file]).not_to eq('undef')
    expect(@blueprint.properties[:master_file]).to eq(@master_file)
    expect(@blueprint.properties[:master_file]).not_to eq('undef')
    expect(@blueprint.properties[:custom_string]).to eq('custom_string')
    expect(@blueprint.properties[:custom_bool]).to be true
    expect(@blueprint.properties[:custom_int]).to eq 42
  end

  it 'setup should load' do
    expect { @blueprint.setup }.not_to raise_error
    expect(@blueprint.properties[:layout_name]).to eq(@spec_bp_name)
    expect(@blueprint.properties[:name]).to eq(@spec_bp_name)
  end

  it 'setup should not load non-layout blueprint' do
    error_raised = false
    begin
      @blueprint.setup 'noname'
    rescue StandardError => e
      puts e.backtrace
      puts e.message
      error_raised = true
    end
    expect(error_raised).to be false
    expect(@blueprint.properties[:layout_name]).to eq('undef')
    expect(@blueprint.properties[:name]).to eq('undef')
  end

  it 'setcore_properties should set core properties' do
    expect { @blueprint.setcore_properties @layout_file, @spec_bp_name }
      .not_to raise_error
    expect(@blueprint.properties[:layout_name]).to eq(@spec_bp_name)
    expect(@blueprint.properties[:name]).to eq(@spec_bp_name)
  end

  it 'blueprint_from_layout should read config and find blueprint name' do
    error_raised = false
    blueprint_name = 'undef'
    begin
      blueprint_name = @blueprint.blueprint_from_layout @layout_file
    rescue
      error_raised = true
    end
    expect(error_raised).to be false
    expect(blueprint_name).to eq(@spec_bp_name)
  end

  it 'validate_blueprint_config should find layout file.' do
    error_raised = false
    valid = false
    begin
      valid = @blueprint.validate_blueprint_config(@spec_bp_name,
                                                   @spec_work_dir)
    rescue
      error_raised = true
    end
    expect(error_raised).to be false
    expect(valid).to be true
  end

  it 'find_blueprint_config should have blueprint properties not set' do
    error_raised = false
    begin
      @blueprint.find_blueprint_config
    rescue
      error_raised = true
    end
    expect(error_raised).to be false
    expect(@blueprint.properties[:name]).to eq('undef')
    expect(@blueprint.properties[:blueprint_name]).to eq('undef')
    expect(@blueprint.properties[:layout_name]).to eq('undef')
    expect(@blueprint.properties[:layout_file]).to eq('undef')
    expect(@blueprint.properties[:master_file]).to eq('undef')
  end

  it 'find_blueprint_config should find blueprint from layout' do
    error_raised = false
    begin
      @blueprint.properties[:work_dir] = @spec_work_dir
      puts "props => #{@blueprint.properties}"
      @blueprint.find_blueprint_config @spec_bp_name
    rescue
      error_raised = true
    end
    expect(error_raised).to be false
    expect(@blueprint.properties[:layout_file]).to eq(@layout_file)
  end

  it 'find_blueprint_nodes should have test nodes' do
    error_raised = false
    begin
      @blueprint.find_blueprint_nodes @spec_bp_name
    rescue
      error_raised = true
    end
    expect(error_raised).to be false
    expect(@blueprint.properties[:nodes]).to include 'util'
    expect(@blueprint.properties[:nodes]).to include 'review'
  end

  it 'findfirst_blueprint_name should find a blueprint name' do
    error_raised = false
    begin
      blueprint_name = @blueprint.findfirst_blueprint_name
    rescue
      error_raised = true
    end
    expect(error_raised).to be false
    expect(blueprint_name).to eq(@spec_bp_name)
  end

  it 'findfirst_blueprint_name should not find blueprint name' do
    error_raised = false
    begin
      @blueprint = Blueprint.new :work_dir => 'spec/fixtures/not_exist'
      blueprint_name = @blueprint.findfirst_blueprint_name
    rescue
      error_raised = true
    end
    expect(error_raised).to be false
    expect(blueprint_name).not_to eq(@spec_bp_name)
    expect(blueprint_name).to eq('undef')
  end

  it 'exist_blueprint? should find blueprints' do
    expect { @blueprint.exist_blueprint? }.not_to raise_error
    expect(@blueprint.exist_blueprint?).to be true
  end

  it 'exist_blueprint? static call without setup' do
    error_raised = false
    begin
      bp_found = Blueprint.new(:work_dir => @spec_work_dir).exist_blueprint?
    rescue
      error_raised = true
    end
    expect(error_raised).to be false
    expect(bp_found).to be true
  end

  it 'exist_blueprint? static call without setting work_dir' do
    error_raised = false
    begin
      bp_found = Blueprint.new.exist_blueprint?
    rescue
      error_raised = true
    end
    expect(error_raised).to be false
    expect(bp_found).to be false
  end

  it 'exist_blueprint? should find blueprints' do
    @blueprint = Blueprint.new :work_dir => 'spec/fixtures/not_exist'
    expect { @blueprint.exist_blueprint? }.not_to raise_error
    expect(@blueprint.exist_blueprint?).to be false
  end
end
