# frozen_string_literal: true

RSpec.describe 'L3 firewall node dsl', :dsl, :firewall, :mddo, :node do
  before do
    nws = Netomox::DSL::Networks.new do
      network 'test-L3' do
        type Netomox::NWTYPE_MDDO_L3
      end
    end
    @l3nw = nws.network('test-L3')
    @tp_key = "#{Netomox::NS_TOPO}:termination-point"
    @l3attr_key = "#{Netomox::NS_MDDO}:l3-node-attributes"
  end

  # rubocop:disable RSpec/ExampleLength
  it 'generate firewall node with full firewall attribute' do
    node_attr = {
      node_type: 'node',
      flags: ['firewall'],
      firewall: {
        cluster_firewall_pairs: [
          {
            primary: {
              name: 'site-a-fw-1',
              atypical_interfaces: [
                { name: 'ge-0/0/0', role: 'fabric', fabric_options: { member_interfaces: ['ge-0/0/0'] } },
                { name: 'ge-0/0/1', role: 'control' }
              ]
            },
            secondary: {
              name: 'site-a-fw-2',
              atypical_interfaces: [
                { name: 'ge-0/0/0', role: 'fabric', fabric_options: { member_interfaces: ['ge-0/0/0'] } },
                { name: 'ge-0/0/1', role: 'control' }
              ]
            }
          }
        ],
        zones: [
          { name: 'WAN', interfaces: %w[ge-0/0/1.0 ge-7/0/1.0] },
          { name: 'LAN', interfaces: %w[ge-0/0/2.0 ge-7/0/2.0] }
        ],
        policies: [
          {
            from_zone: 'LAN', to_zone: 'WAN',
            rules: [
              { name: 'DEFAULT', action: 'permit',
                application: 'any', source_address: 'any', destination_address: 'any' }
            ]
          },
          {
            from_zone: 'WAN', to_zone: 'LAN',
            rules: [
              { name: 'DEFAULT', action: 'deny',
                application: 'any', source_address: 'any', destination_address: 'any' }
            ]
          }
        ]
      }
    }
    node = Netomox::DSL::Node.new(@l3nw, 'fw-node') do
      attribute(node_attr)
    end
    node_data = {
      'node-id' => 'fw-node',
      @tp_key => [],
      @l3attr_key => {
        'node-type' => 'node',
        'prefix' => [],
        'static-route' => [],
        'flag' => ['firewall'],
        'firewall' => {
          'cluster-firewall-pair' => [
            {
              'primary' => {
                'name' => 'site-a-fw-1',
                'atypical-interface' => [
                  { 'name' => 'ge-0/0/0', 'role' => 'fabric',
                    'fabric-options' => { 'member-interface' => ['ge-0/0/0'] } },
                  { 'name' => 'ge-0/0/1', 'role' => 'control' }
                ]
              },
              'secondary' => {
                'name' => 'site-a-fw-2',
                'atypical-interface' => [
                  { 'name' => 'ge-0/0/0', 'role' => 'fabric',
                    'fabric-options' => { 'member-interface' => ['ge-0/0/0'] } },
                  { 'name' => 'ge-0/0/1', 'role' => 'control' }
                ]
              }
            }
          ],
          'zone' => [
            { 'name' => 'WAN', 'interface' => %w[ge-0/0/1.0 ge-7/0/1.0] },
            { 'name' => 'LAN', 'interface' => %w[ge-0/0/2.0 ge-7/0/2.0] }
          ],
          'policy' => [
            {
              'from-zone' => 'LAN', 'to-zone' => 'WAN',
              'rule' => [
                { 'name' => 'DEFAULT', 'action' => 'permit',
                  'application' => 'any', 'source-address' => 'any', 'destination-address' => 'any' }
              ]
            },
            {
              'from-zone' => 'WAN', 'to-zone' => 'LAN',
              'rule' => [
                { 'name' => 'DEFAULT', 'action' => 'deny',
                  'application' => 'any', 'source-address' => 'any', 'destination-address' => 'any' }
              ]
            }
          ]
        }
      }
    }
    expect(node.topo_data).to eq node_data
  end
  # rubocop:enable RSpec/ExampleLength

  it 'does not include firewall key for non-firewall node' do
    node_attr = { node_type: 'node', prefixes: [{ prefix: '192.168.0.0/24', metric: 1, flags: [] }] }
    node = Netomox::DSL::Node.new(@l3nw, 'normal-node') do
      attribute(node_attr)
    end
    expect(node.topo_data[@l3attr_key]).not_to have_key('firewall')
  end
end
