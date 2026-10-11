# frozen_string_literal: true

RSpec.describe 'check attribute conversion functions (fhrp)', :attr, :convert, :fhrp do
  let(:origin_attr) do
    {
      description: 'to_site-b',
      ip_addrs: %w[192.168.101.2/24],
      flags: [],
      fhrp: [
        {
          protocol: 'vrrp',
          group_id: 1,
          virtual_addresses: %w[192.168.101.1],
          priority: 150,
          preempt: true,
          source_address: '192.168.101.2/24',
          active: true
        }
      ]
    }
  end
  let(:networks) do
    attr = origin_attr
    Netomox::DSL::Networks.new do
      network 'layer3' do
        type Netomox::NWTYPE_MDDO_L3
        node 'node1' do
          term_point('eth1') { attribute(attr) }
        end
      end
    end
  end
  let(:topology_tp) do
    Netomox::Topology::Networks.new(networks.topo_data).find_network('layer3')&.find_node_by_name('node1')
                               &.find_tp_by_name('eth1')
  end

  it 'can convert topology-attribute to dsl-attribute' do
    converted_attr = Netomox.convert_attr_topo2dsl(topology_tp.attribute.to_data)
    expect(converted_attr).to eq origin_attr
  end

  it 'can build topology again from converted dsl-attribute (round trip)' do
    converted_attr = Netomox.convert_attr_topo2dsl(topology_tp.attribute.to_data)
    nws = Netomox::DSL::Networks.new do
      network 'layer3' do
        type Netomox::NWTYPE_MDDO_L3
        node 'node1' do
          term_point('eth1') { attribute(converted_attr) }
        end
      end
    end
    expect(nws.topo_data).to eq networks.topo_data
  end

  it 'does not add fhrp key to the converted attribute of term-point without fhrp' do
    attr = { description: 'x', ip_addrs: %w[192.168.0.1/24], flags: [] }
    nws = Netomox::DSL::Networks.new do
      network 'layer3' do
        type Netomox::NWTYPE_MDDO_L3
        node('node1') { term_point('eth1') { attribute(attr) } }
      end
    end
    tp = Netomox::Topology::Networks.new(nws.topo_data).find_network('layer3')&.find_node_by_name('node1')
                                    &.find_tp_by_name('eth1')
    expect(Netomox.convert_attr_topo2dsl(tp.attribute.to_data)).to eq attr
  end
end
