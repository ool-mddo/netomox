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
              node: 'site-a-fw-1',
              pair: {
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
              },
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

  # rubocop:disable-next RSpec/ExampleLength
  it 'has firewall node attribute with all sections' do
    attr = @nws.find_network('nw_l3')&.find_node_by_name('fw-node')&.attribute
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'node-type' => 'node',
      'prefix' => [],
      'static-route' => [],
      'flag' => ['firewall'],
      'firewall' => {
        'node' => 'site-a-fw-1',
        'pair' => {
          'primary' => {
            'name' => 'site-a-fw-1',
            'atypical_interfaces' => [
              { 'name' => 'ge-0/0/0', 'role' => 'fabric',
                'fabric_options' => { 'member_interfaces' => ['ge-0/0/0'] } },
              { 'name' => 'ge-0/0/1', 'role' => 'control' }
            ]
          },
          'secondary' => {
            'name' => 'site-a-fw-2',
            'atypical_interfaces' => [
              { 'name' => 'ge-0/0/0', 'role' => 'fabric',
                'fabric_options' => { 'member_interfaces' => ['ge-0/0/0'] } },
              { 'name' => 'ge-0/0/1', 'role' => 'control' }
            ]
          }
        },
        'zones' => [
          { 'name' => 'trust',   'interfaces' => [] },
          { 'name' => 'untrust', 'interfaces' => [] },
          { 'name' => 'WAN',     'interfaces' => %w[ge-0/0/1.0 ge-7/0/1.0] },
          { 'name' => 'LAN',     'interfaces' => %w[ge-0/0/2.0 ge-7/0/2.0] }
        ],
        'policies' => [
          {
            'from_zone' => 'trust', 'to_zone' => 'trust',
            'rules' => [
              { 'name' => 'default-permit', 'action' => 'permit',
                'application' => 'any', 'source_address' => 'any', 'destination_address' => 'any' }
            ]
          },
          {
            'from_zone' => 'LAN', 'to_zone' => 'WAN',
            'rules' => [
              { 'name' => 'DEFAULT', 'action' => 'permit',
                'application' => 'any', 'source_address' => 'any', 'destination_address' => 'any' }
            ]
          },
          {
            'from_zone' => 'WAN', 'to_zone' => 'LAN',
            'rules' => [
              { 'name' => 'DEFAULT', 'action' => 'deny',
                'application' => 'any', 'source_address' => 'any', 'destination_address' => 'any' }
            ]
          }
        ]
      }
    }
    expect(attr&.to_data).to eq expected_attr
  end

  it 'does not have firewall key for non-firewall node' do
    attr = @nws.find_network('nw_l3')&.find_node_by_name('normal-node')&.attribute
    expect(attr&.to_data).not_to have_key('firewall')
  end

  it 'can access firewall cluster pair info' do
    attr = @nws.find_network('nw_l3')&.find_node_by_name('fw-node')&.attribute
    pair = attr&.firewall&.pair
    expect(pair&.dig('primary', 'name')).to eq 'site-a-fw-1'
    expect(pair&.dig('secondary', 'name')).to eq 'site-a-fw-2'
  end

  it 'can access atypical interface fabric options' do
    attr = @nws.find_network('nw_l3')&.find_node_by_name('fw-node')&.attribute
    atypical_interfaces = attr&.firewall&.pair&.dig('primary', 'atypical_interfaces')
    fabric_if = atypical_interfaces&.find { |i| i['role'] == 'fabric' }
    expect(fabric_if&.dig('fabric_options', 'member_interfaces')).to eq ['ge-0/0/0']
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
