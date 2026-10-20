# frozen_string_literal: true

RSpec.describe 'check fhrp attribute of L3 term-point (Topology)', :attr, :fhrp, :tp do
  let(:fhrp_data) do
    [
      {
        'protocol' => 'vrrp',
        'group-id' => 1,
        'virtual-address' => %w[192.168.101.1],
        'priority' => 150,
        'preempt' => true,
        'source-address' => '192.168.101.2/24',
        'active' => true
      },
      {
        'protocol' => 'hsrp',
        'group-id' => 10,
        'virtual-address' => %w[192.168.101.254],
        'priority' => 100,
        'preempt' => false,
        'source-address' => '192.168.101.2/24',
        'active' => false
      }
    ]
  end
  let(:attr_key) { 'mddo-topology:l3-termination-point-attributes' }
  let(:tp_with_fhrp) do
    topology_tp({ 'description' => 'eth1', 'ip-address' => %w[192.168.101.2/24], 'flag' => [], 'fhrp' => fhrp_data })
  end
  let(:tp_without_fhrp) do
    topology_tp({ 'description' => 'eth1', 'ip-address' => %w[192.168.101.2/24], 'flag' => [] })
  end

  def topology_tp(attr_data)
    topo_data = {
      'tp-id' => 'eth1',
      attr_key => attr_data
    }
    Netomox::Topology::TermPoint.new(topo_data, '')
  end

  it 'parses fhrp as MddoFhrp objects', :aggregate_failures do
    fhrp = tp_with_fhrp.attribute.fhrp
    expect(fhrp.length).to eq 2
    expect(fhrp).to all(be_a(Netomox::Topology::MddoFhrp))
    expect(fhrp[0].protocol).to eq 'vrrp'
    expect(fhrp[0].group_id).to eq 1
    expect(fhrp[0].virtual_addresses).to eq %w[192.168.101.1]
    expect(fhrp[0].priority).to eq 150
    expect(fhrp[0].preempt).to be true
    expect(fhrp[0].source_address).to eq '192.168.101.2/24'
    expect(fhrp[0].active).to be true
    expect(fhrp[1].protocol).to eq 'hsrp'
    expect(fhrp[1].group_id).to eq 10
    expect(fhrp[1].active).to be false
  end

  it 'accepts string number for group-id and priority' do
    tp = topology_tp({ 'fhrp' => [{ 'protocol' => 'vrrp', 'group-id' => '2', 'priority' => '120' }] })
    expect(tp.attribute.fhrp[0].group_id).to eq 2
    expect(tp.attribute.fhrp[0].priority).to eq 120
  end

  it 'returns empty fhrp if the term-point does not have fhrp' do
    expect(tp_without_fhrp.attribute.fhrp).to eq []
    expect(tp_without_fhrp.attribute.ip_addrs).to eq %w[192.168.101.2/24]
  end

  it 'is not empty attribute when it has only fhrp' do
    tp = topology_tp({ 'fhrp' => fhrp_data })
    expect(tp.attribute).not_to be_empty
  end

  it 'keeps fhrp in #to_data (round trip)' do
    attr_data = tp_with_fhrp.attribute.to_data
    expect(attr_data['fhrp']).to eq fhrp_data
    expect(attr_data['ip-address']).to eq %w[192.168.101.2/24]
    # re-parse
    expect(topology_tp(attr_data).attribute.to_data['fhrp']).to eq fhrp_data
  end

  it 'does not output fhrp key in #to_data if the term-point does not have fhrp' do
    expect(tp_without_fhrp.attribute.to_data).not_to have_key('fhrp')
  end

  it 'keeps fhrp through term-point #to_data' do
    expect(tp_with_fhrp.to_data[attr_key]['fhrp']).to eq fhrp_data
  end
end
