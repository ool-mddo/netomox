# frozen_string_literal: true

RSpec.describe 'check attribute conversion functions' do
  before do
    origin_attr = {
      router_id: '10.0.0.1',
      confederation_id: 65_531,
      confederation_members: [65_532],
      peer_groups: [],
      route_reflector: false,
      policies: [{ 'name' => 'test policy 1' }], # TBA
      prefix_sets: [{ 'name' => 'prefix set 1' }], # TBA
      as_path_sets: [{ 'name' => 'as-path set 1' }], # TBA
      community_sets: [{ 'name' => 'community set 1' }], # TBA
      redistribute_list: [], # TBA
      flags: %w[foo bar]
    }
    nws = Netomox::DSL::Networks.new do
      network 'bgp_proc' do
        type Netomox::NWTYPE_MDDO_BGP_PROC
        node 'node1' do
          attribute(**origin_attr)
        end
      end
    end
    @topo_data = nws.topo_data # RFC8345 json data
    @expected_attr = origin_attr
  end

  it 'can convert topology-attribute to dsl-attribute' do
    nws = Netomox::Topology::Networks.new(@topo_data)
    node = nws.find_network('bgp_proc')&.find_node_by_name('node1')
    converted_attr = Netomox.convert_attr_topo2dsl(node.attribute.to_data)
    expect(converted_attr).to eq @expected_attr
  end
end
