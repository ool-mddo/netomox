# frozen_string_literal: true

RSpec.describe 'check node attribute with Mddo-model' do
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
              { prefix: '192.168.0.0/24', metric: 1, flags: ['test'] },
              { prefix: '192.168.1.0/24', metric: 10, flags: %w[foo bar] }
            ],
            static_routes: [
              { prefix: '172.16.1.0/24', next_hop: '10.0.0.1', metric: 1 },
              { prefix: '172.16.2.0/24', next_hop: '10.0.1.0', description: 'test' }
            ]
          )
        end
      end
      network 'nw_ospf' do
        type Netomox::NWTYPE_MDDO_OSPF_AREA
        node('node1') do
          attribute(
            node_type: 'node',
            router_id: '10.0.0.1',
            process_id: 1,
            log_adjacency_change: false,
            redistribute_list: [{ protocol: 'static', metric_type: 2 }],
            flags: %w[foo bar]
          )
        end
      end
      network 'nw_bgp_proc' do
        type Netomox::NWTYPE_MDDO_BGP_PROC
        node('node1') do
          attribute(
            router_id: '10.0.0.1',
            confederation_id: 65_531,
            confederation_members: [65_532],
            policies: [
              {
                default: { actions: [{ target: 'reject' }] },
                name: 'ipv4-core',
                statements: [
                  {
                    actions: [{ target: 'accept' }],
                    conditions: [{ protocol: 'bgp' }],
                    if: 'if',
                    name: 'bgp'
                  }
                ]
              }
            ],
            prefix_sets: [{ name: 'default-ipv4', prefixes: [{ prefix: '0.0.0.0/0' }] }],
            as_path_sets: [{ group_name: 'any', as_path: [{ name: 'any', pattern: '.*' }] }],
            community_sets: [{ communities: [{ community: '65518:1' }], name: 'aggregated' }],
            redistribute_list: [], # TBA
            flags: %w[foo bar]
          )
        end
      end
      network 'nw_bgp_as' do
        type Netomox::NWTYPE_MDDO_BGP_AS
        node('node1') do
          attribute(
            as_number: 65_550,
            flags: %w[foo bar]
          )
        end
      end
    end
    topo_data = nws.topo_data
    @nws = Netomox::Topology::Networks.new(topo_data)
    @default_diff_state = { backward: nil, forward: :kept, pair: '' }
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
        { 'prefix' => '192.168.0.0/24', 'metric' => 1, 'flag' => ['test'] },
        { 'prefix' => '192.168.1.0/24', 'metric' => 10, 'flag' => %w[foo bar] }
      ],
      'static-route' => [
        {
          'prefix' => '172.16.1.0/24', 'next-hop' => '10.0.0.1',
          'metric' => 1, 'interface' => '', 'preference' => 1, 'description' => ''
        },
        {
          'prefix' => '172.16.2.0/24', 'next-hop' => '10.0.1.0',
          'metric' => 10, 'interface' => '', 'preference' => 1, 'description' => 'test'
        }
      ],
      'flag' => []
    }
    expect(attr&.to_data).to eq expected_attr
  end

  it 'has MDDO ospf node attribute' do
    attr = @nws.find_network('nw_ospf')&.find_node_by_name('node1')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'node-type' => 'node',
      'router-id' => '10.0.0.1',
      'router-id-source' => 'static',
      'process-id' => 1,
      'log-adjacency-change' => false,
      'redistribute' => [{ 'protocol' => 'static', 'metric-type' => 2 }],
      'flag' => %w[foo bar]
    }
    expect(attr&.to_data).to eq expected_attr
  end

  # rubocop:disable RSpec/ExampleLength
  it 'has MDDO bgp-proc node attribute' do
    attr = @nws.find_network('nw_bgp_proc')&.find_node_by_name('node1')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'router-id' => '10.0.0.1',
      'confederation-id' => 65_531,
      'confederation-member' => [65_532],
      'route-reflector' => false,
      'peer-group' => [],
      'policy' => [
        {
          'default' => {
            'actions' => [{ 'target' => 'reject' }]
          },
          'name' => 'ipv4-core',
          'statements' => [
            {
              'actions' => [{ 'target' => 'accept' }],
              'conditions' => [{ 'protocol' => 'bgp' }],
              'if' => 'if',
              'name' => 'bgp'
            }
          ]
        }
      ],
      'prefix-set' => [
        {
          'name' => 'default-ipv4', 'prefixes' => [{ 'prefix' => '0.0.0.0/0' }]
        }
      ],
      'as-path-set' => [
        {
          'group-name' => 'any', 'as-path' => [{ 'name' => 'any', 'pattern' => '.*' }]
        }
      ],
      'community-set' => [
        {
          'communities' => [{ 'community' => '65518:1' }], 'name' => 'aggregated'
        }
      ],
      'redistribute' => [],
      'flag' => %w[foo bar]
    }
    expect(attr&.to_data).to eq expected_attr
  end
  # rubocop:enable RSpec/ExampleLength

  it 'has MDDO bgp-as node attribute' do
    attr = @nws.find_network('nw_bgp_as')&.find_node_by_name('node1')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'as-number' => 65_550,
      'flag' => %w[foo bar]
    }
    expect(attr&.to_data).to eq expected_attr
  end
end
