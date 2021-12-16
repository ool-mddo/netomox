# frozen_string_literal: true

RSpec.describe 'check node attribute with RFC' do
  before do
    nws = Netomox::DSL::Networks.new do
      network 'nw1' do
        type Netomox::NWTYPE_MDDO_L1
        node('node1') do
          attribute(
            os_type: 'cisco_ios',
            flags: %w[layer1 node]
          )
        end
      end
      network 'nw2' do
        type Netomox::NWTYPE_MDDO_L2
        node('node1') do
          attribute(
            name: 'node1',
            vlan_id: 10,
            flags: %w[layer2 node]
          )
        end
      end
      network 'nw3' do
        type Netomox::NWTYPE_MDDO_L3
        node('node1') do
          attribute(
            node_type: 'node',
            prefixes: [
              { prefix: '192.168.0.0/24', metric: 1, flags: 'test'},
              { prefix: '192.168.1.0/24', metric: 10, flags: %w[foo bar]}
            ]
          )
        end
      end
    end
    topo_data = nws.topo_data
    @nws = Netomox::Topology::Networks.new(topo_data)
    @default_diff_state = { :backward=>nil, :forward=>:kept, :pair=>"" }
  end

  it 'has MDDO layer1 node attribute' do
    attr = @nws.find_network('nw1')&.find_node_by_name('node1')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'os-type' => 'cisco_ios',
      'flag' => %w[layer1 node]
    }
    expect(attr&.to_data).to eq expected_attr
  end

  it 'has MDDO layer2 node attribute' do
    attr = @nws.find_network('nw2')&.find_node_by_name('node1')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'name' => 'node1',
      'vlan-id' => 10,
      'flag' => %w[layer2 node]
    }
    expect(attr&.to_data).to eq expected_attr
  end

  it 'has MDDO layer3 node attribute' do
    attr = @nws.find_network('nw3')&.find_node_by_name('node1')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'node-type' => 'node',
      'prefix' => [
        { '_diff_state_' => @default_diff_state, 'prefix' => '192.168.0.0/24', 'metric' => 1, 'flag' => 'test'},
        { '_diff_state_' => @default_diff_state, 'prefix' => '192.168.1.0/24', 'metric' => 10, 'flag' => %w[foo bar]}
      ]
    }
    expect(attr&.to_data).to eq expected_attr
  end
end
