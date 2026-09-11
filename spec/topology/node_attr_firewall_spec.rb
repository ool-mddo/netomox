# frozen_string_literal: true

RSpec.describe 'check L3 firewall node attribute with Mddo-model' do
  before do
    nws = Netomox::DSL::Networks.new do
      network 'nw_l3' do
        type Netomox::NWTYPE_MDDO_L3
        node('fw-node') do
          attribute(
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
                { name: 'trust', interfaces: [] },
                { name: 'untrust', interfaces: [] },
                { name: 'WAN', interfaces: %w[ge-0/0/1.0 ge-7/0/1.0] },
                { name: 'LAN', interfaces: %w[ge-0/0/2.0 ge-7/0/2.0] }
              ],
              policies: [
                {
                  from_zone: 'trust', to_zone: 'trust',
                  rules: [
                    { name: 'default-permit', action: 'permit',
                      application: 'any', source_address: 'any', destination_address: 'any' }
                  ]
                },
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
          )
        end
        node('normal-node') do
          attribute(
            node_type: 'node',
            prefixes: [{ prefix: '192.168.0.0/24', metric: 1, flags: [] }]
          )
        end
      end
    end
    topo_data = nws.topo_data
    @nws = Netomox::Topology::Networks.new(topo_data)
    @default_diff_state = { backward: nil, forward: :kept, pair: '' }
  end

  # rubocop:disable RSpec/ExampleLength
  it 'has firewall node attribute with all sections' do
    attr = @nws.find_network('nw_l3')&.find_node_by_name('fw-node')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
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
          { 'name' => 'trust',   'interface' => [] },
          { 'name' => 'untrust', 'interface' => [] },
          { 'name' => 'WAN',     'interface' => %w[ge-0/0/1.0 ge-7/0/1.0] },
          { 'name' => 'LAN',     'interface' => %w[ge-0/0/2.0 ge-7/0/2.0] }
        ],
        'policy' => [
          {
            'from-zone' => 'trust', 'to-zone' => 'trust',
            'rule' => [
              { 'name' => 'default-permit', 'action' => 'permit',
                'application' => 'any', 'source-address' => 'any', 'destination-address' => 'any' }
            ]
          },
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
    expect(attr&.to_data).to eq expected_attr
  end
  # rubocop:enable RSpec/ExampleLength

  it 'does not have firewall key for non-firewall node' do
    attr = @nws.find_network('nw_l3')&.find_node_by_name('normal-node')&.attribute
    expect(attr&.to_data).not_to have_key('firewall')
  end

  it 'can access firewall cluster pair info' do
    attr = @nws.find_network('nw_l3')&.find_node_by_name('fw-node')&.attribute
    pair = attr&.firewall&.cluster_firewall_pairs&.first
    expect(pair&.primary&.name).to eq 'site-a-fw-1'
    expect(pair&.secondary&.name).to eq 'site-a-fw-2'
  end

  it 'can access atypical interface fabric options' do
    attr = @nws.find_network('nw_l3')&.find_node_by_name('fw-node')&.attribute
    cluster_pair = attr&.firewall&.cluster_firewall_pairs&.first
    primary_node = cluster_pair&.primary
    fabric_if = primary_node&.atypical_interfaces&.find { |i| i.role == 'fabric' }
    expect(fabric_if&.fabric_options&.member_interfaces).to eq ['ge-0/0/0']
  end

  it 'can access firewall zones' do
    attr = @nws.find_network('nw_l3')&.find_node_by_name('fw-node')&.attribute
    zone_names = attr&.firewall&.zones&.map(&:name)
    expect(zone_names).to eq %w[trust untrust WAN LAN]
  end

  it 'can access firewall policies and rules' do
    attr = @nws.find_network('nw_l3')&.find_node_by_name('fw-node')&.attribute
    wan_to_lan = attr&.firewall&.policies&.find { |p| p.from_zone == 'WAN' && p.to_zone == 'LAN' }
    expect(wan_to_lan&.rules&.first&.action).to eq 'deny'
  end

  it 'identifies firewall node by flags' do
    fw_node = @nws.find_network('nw_l3')&.find_node_by_name('fw-node')
    normal_node = @nws.find_network('nw_l3')&.find_node_by_name('normal-node')
    expect(fw_node&.attribute&.flags).to include('firewall')
    expect(normal_node&.attribute&.flags).not_to include('firewall')
  end
end
