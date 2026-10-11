# frozen_string_literal: true

RSpec.describe 'termination point diff with L3 attribute (fhrp)', :attr, :diff, :fhrp, :tp do
  def fhrp_group(priority: 150, group_id: 1)
    {
      protocol: 'vrrp', group_id: group_id, virtual_addresses: %w[192.168.101.1], priority: priority,
      preempt: true, source_address: '192.168.101.2/24', active: true
    }
  end

  def topology_tp(tp_attr)
    nws = Netomox::DSL::Networks.new do
      network 'nwX' do
        type Netomox::NWTYPE_MDDO_L3
        node('nd') { term_point('tpX') { attribute(tp_attr) } }
      end
    end
    Netomox::Topology::Networks.new(nws.topo_data).find_network('nwX').find_node_by_name('nd').find_tp_by_name('tpX')
  end

  let(:base_attr) { { ip_addrs: %w[192.168.101.2/24] } }
  let(:tp_no_fhrp) { topology_tp(base_attr) }
  let(:tp_fhrp) { topology_tp(base_attr.merge(fhrp: [fhrp_group])) }

  it 'kept tp attribute with fhrp' do
    d_tp = tp_fhrp.diff(topology_tp(base_attr.merge(fhrp: [fhrp_group])))
    expect(d_tp.diff_state.detect).to eq :kept
    expect(d_tp.attribute.diff_state.detect).to eq :kept
  end

  it 'detects added fhrp' do
    d_tp = tp_no_fhrp.diff(tp_fhrp)
    expect(d_tp.diff_state.detect).to eq :changed
    expect(d_tp.attribute.diff_state.detect).to eq :changed
  end

  it 'detects deleted fhrp' do
    d_tp = tp_fhrp.diff(tp_no_fhrp)
    expect(d_tp.diff_state.detect).to eq :changed
    expect(d_tp.attribute.diff_state.detect).to eq :changed
  end

  it 'detects changed fhrp parameter (priority)' do
    d_tp = tp_fhrp.diff(topology_tp(base_attr.merge(fhrp: [fhrp_group(priority: 100)])))
    expect(d_tp.diff_state.detect).to eq :changed
    expect(d_tp.attribute.diff_state.detect).to eq :changed
  end

  it 'detects added fhrp group' do
    d_tp = tp_fhrp.diff(topology_tp(base_attr.merge(fhrp: [fhrp_group, fhrp_group(group_id: 2)])))
    expect(d_tp.attribute.diff_state.detect).to eq :changed
  end
end
