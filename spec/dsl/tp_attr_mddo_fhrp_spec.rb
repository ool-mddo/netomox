# frozen_string_literal: true

RSpec.describe 'check fhrp attribute of L3 term-point (DSL)', :attr, :dsl, :fhrp, :tp do
  let(:vrrp_attr) do
    {
      protocol: 'vrrp',
      group_id: 1,
      virtual_addresses: %w[192.168.101.1],
      priority: 150,
      preempt: true,
      source_address: '192.168.101.2/24',
      active: true
    }
  end
  let(:hsrp_attr) do
    {
      protocol: 'hsrp',
      group_id: 10,
      virtual_addresses: %w[192.168.101.254],
      priority: 100,
      preempt: false,
      source_address: '192.168.101.2/24',
      active: false
    }
  end
  let(:attr_key) { 'mddo-topology:l3-termination-point-attributes' }

  def tp_topo_data(tp_attr)
    nws = Netomox::DSL::Networks.new do
      network 'nw3' do
        type Netomox::NWTYPE_MDDO_L3
        node('node1') do
          term_point('eth1') { attribute(tp_attr) }
        end
      end
    end
    nws.topo_data['ietf-network:networks']['network'][0]['node'][0]['ietf-network-topology:termination-point'][0]
  end

  it 'outputs fhrp as topology data (kebab-case keys)' do
    attr = tp_topo_data({ ip_addrs: %w[192.168.101.2/24], fhrp: [vrrp_attr] })[attr_key]
    expect(attr['ip-address']).to eq %w[192.168.101.2/24]
    expect(attr['fhrp']).to eq [
      {
        'protocol' => 'vrrp',
        'group-id' => 1,
        'virtual-address' => %w[192.168.101.1],
        'priority' => 150,
        'preempt' => true,
        'source-address' => '192.168.101.2/24',
        'active' => true
      }
    ]
  end

  it 'outputs multiple fhrp groups (vrrp and hsrp)' do
    attr = tp_topo_data({ ip_addrs: %w[192.168.101.2/24], fhrp: [vrrp_attr, hsrp_attr] })[attr_key]
    expect(attr['fhrp'].map { |f| [f['protocol'], f['group-id']] }).to eq [['vrrp', 1], ['hsrp', 10]]
  end

  it 'does not output fhrp key if the term-point does not have fhrp' do
    attr = tp_topo_data({ ip_addrs: %w[192.168.101.2/24] })[attr_key]
    expect(attr).not_to have_key('fhrp')
    attr = tp_topo_data({ ip_addrs: %w[192.168.101.2/24], fhrp: [] })[attr_key]
    expect(attr).not_to have_key('fhrp')
  end

  it 'is not empty attribute when it has only fhrp' do
    attr = Netomox::DSL::MddoL3TPAttribute.new(fhrp: [vrrp_attr])
    expect(attr).not_to be_empty
    expect(Netomox::DSL::MddoL3TPAttribute.new).to be_empty
  end

  it 'fills default values of fhrp' do
    attr = Netomox::DSL::MddoL3TPAttribute.new(fhrp: [{ protocol: 'vrrp', group_id: 1 }])
    expect(attr.topo_data['fhrp'][0]).to eq(
      'protocol' => 'vrrp',
      'group-id' => 1,
      'virtual-address' => [],
      'priority' => 0,
      'preempt' => false,
      'source-address' => '',
      'active' => false
    )
  end
end
