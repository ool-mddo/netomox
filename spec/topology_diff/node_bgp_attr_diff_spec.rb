# frozen_string_literal: true

RSpec.describe 'bgp-proc bgp-policy related attribute', :attr, :bgp, :diff, :node do
  before do
    parent = lambda do |name|
      nws = Netomox::DSL::Networks.new
      Netomox::DSL::Network.new(nws, name) do
        type Netomox::NWTYPE_MDDO_BGP_PROC
      end
    end

    prefix_sets_list = [
      [{ name: 'default-ipv4', prefixes: [{ prefix: '0.0.0.0/0' }] }], # [0] original
      [{ name: 'default-ipv4', prefixes: [{ prefix: '0.0.0.0/0' }] }], # [1] kept (unchanged)
      [{ name: 'default-ipv4', prefixes: [{ prefix: '0.0.0.0/1' }] }], # [2] changed prefix
      [{ name: 'default-ipv4', prefixes: [{ prefix: '0.0.0.0/0' }, { prefix: '10.0.0.0/24' }] }], # [3] added prefix
      [
        { name: 'default-ipv4', prefixes: [{ prefix: '0.0.0.0/0' }] },
        { name: 'test-prefix', prefixes: [{ prefix: '10.0.0.0/24' }] }
      ] # [4] added prefix-set
    ]
    @ps_nodes = prefix_sets_list.map do |prefix_sets|
      node = Netomox::DSL::Node.new(parent.call('bgp_proc'), 'nodeX') do
        attribute(router_id: '10.0.0.1', prefix_sets: prefix_sets)
      end
      Netomox::Topology::Node.new(node.topo_data, '')
    end

    as_path_sets_list = [
      [{ group_name: 'any', as_path: { name: 'any', pattern: '.*' } }], # [0] original
      [{ group_name: 'any', as_path: { name: 'any', pattern: '.*' } }], # [1] kept (unchanged)
      [{ group_name: 'any', as_path: { name: 'any', pattern: '..*' } }], # [2] changed as-path pattern
      [
        { group_name: 'any', as_path: { name: 'any', pattern: '.*' } },
        { group_name: 'hoge', as_path: { name: 'hoge', pattern: '10\.*' } }
      ] # [3] added as-path-set
    ]
    @aps_nodes = as_path_sets_list.map do |as_path_sets|
      node = Netomox::DSL::Node.new(parent.call('bgp_proc'), 'nodeX') do
        attribute(router_id: '10.0.0.1', as_path_sets: as_path_sets)
      end
      Netomox::Topology::Node.new(node.topo_data, '')
    end

    community_sets_list = [
      [{ communities: [{ community: '65518:1' }], name: 'aggregated' }], # [0] original
      [{ communities: [{ community: '65518:1' }], name: 'aggregated' }], # [1] kept (unchanged)
      [{ communities: [{ community: '65518:2 ' }], name: 'aggregated' }], # [2] changed community
      [{ communities: [{ community: '65518:1 ' }, { community: '65518:2' }], name: 'aggregated' }], # [3] added communiy
      [
        { communities: [{ community: '65518:1' }], name: 'aggregated' },
        { communities: [{ community: '65518:2' }], name: 'testing' }
      ] # [4] added community-set
    ]
    @cs_nodes = community_sets_list.map do |community_sets|
      node = Netomox::DSL::Node.new(parent.call('bgp_proc'), 'nodeX') do
        attribute(router_id: '10.0.0.1', community_sets: community_sets)
      end
      Netomox::Topology::Node.new(node.topo_data, '')
    end
  end

  context 'prefix-set diff' do
    it 'kept prefix-sets attribute' do
      d_node = @ps_nodes[0].diff(@ps_nodes[1])
      expect(d_node.diff_state.detect).to eq :kept
      expect(d_node.attribute.diff_state.detect).to eq :kept
      dd_expected = []
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'changed prefix in a prefix-set' do
      d_node = @ps_nodes[0].diff(@ps_nodes[2])
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [
        ['-', 'prefix-set[0]', { 'name' => 'default-ipv4', 'prefixes' => [{ 'prefix' => '0.0.0.0/0' }] }],
        ['+', 'prefix-set[0]', { 'name' => 'default-ipv4', 'prefixes' => [{ 'prefix' => '0.0.0.0/1' }] }]
      ]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'added prefix in a prefix-set' do
      d_node = @ps_nodes[0].diff(@ps_nodes[3])
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [['+', 'prefix-set[0].prefixes[1]', { 'prefix' => '10.0.0.0/24' }]]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'deleted prefix in a prefix-set' do
      d_node = @ps_nodes[3].diff(@ps_nodes[0])
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [['-', 'prefix-set[0].prefixes[1]', { 'prefix' => '10.0.0.0/24' }]]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'added a prefix-set' do
      d_node = @ps_nodes[0].diff(@ps_nodes[4])
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [
        ['+', 'prefix-set[1]', { 'name' => 'test-prefix', 'prefixes' => [{ 'prefix' => '10.0.0.0/24' }] }]
      ]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'deleted a prefix-set' do
      d_node = @ps_nodes[4].diff(@ps_nodes[0])
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [
        ['-', 'prefix-set[1]', { 'name' => 'test-prefix', 'prefixes' => [{ 'prefix' => '10.0.0.0/24' }] }]
      ]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end
  end

  context 'as-path-set diff' do
    it 'kept as-path-set attribute' do
      d_node = @aps_nodes[0].diff(@aps_nodes[1])
      expect(d_node.diff_state.detect).to eq :kept
      expect(d_node.attribute.diff_state.detect).to eq :kept
      dd_expected = []
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'changed as-path pattern in a as-path-set' do
      d_node = @aps_nodes[0].diff(@aps_nodes[2])
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [
        ['-', 'as-path-set[0]', { 'as-path' => { 'name' => 'any', 'pattern' => '.*' }, 'group-name' => 'any' }],
        ['+', 'as-path-set[0]', { 'as-path' => { 'name' => 'any', 'pattern' => '..*' }, 'group-name' => 'any' }]
      ]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'added as-path-set' do
      d_node = @aps_nodes[0].diff(@aps_nodes[3])
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [
        ['+', 'as-path-set[1]', { 'as-path' => { 'name' => 'hoge', 'pattern' => '10\\.*' }, 'group-name' => 'hoge' }]
      ]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'deleted as-path-set' do
      d_node = @aps_nodes[3].diff(@aps_nodes[0])
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [
        ['-', 'as-path-set[1]', { 'as-path' => { 'name' => 'hoge', 'pattern' => '10\\.*' }, 'group-name' => 'hoge' }]
      ]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end
  end

  context 'community-set diff' do
    it 'kept community-sets attribute' do
      d_node = @cs_nodes[0].diff(@cs_nodes[1])
      expect(d_node.diff_state.detect).to eq :kept
      expect(d_node.attribute.diff_state.detect).to eq :kept
      dd_expected = []
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'changed community in a community-set' do
      d_node = @cs_nodes[0].diff(@cs_nodes[2])
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [
        ['-', 'community-set[0]', { 'communities' => [{ 'community' => '65518:1' }], 'name' => 'aggregated' }],
        ['+', 'community-set[0]', { 'communities' => [{ 'community' => '65518:2 ' }], 'name' => 'aggregated' }]
      ]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'added community in a community-set' do
      d_node = @cs_nodes[0].diff(@cs_nodes[3])
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [
        ['-', 'community-set[0]', { 'communities' => [{ 'community' => '65518:1' }], 'name' => 'aggregated' }],
        ['+', 'community-set[0]', { 'communities' => [{ 'community' => '65518:1 ' }, { 'community' => '65518:2' }], 'name' => 'aggregated' }]
      ]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'deleted community in a community-set' do
      d_node = @cs_nodes[3].diff(@cs_nodes[0])
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [
        ['-', 'community-set[0]', { 'communities' => [{ 'community' => '65518:1 ' }, { 'community' => '65518:2' }], 'name' => 'aggregated' }],
        ['+', 'community-set[0]', { 'communities' => [{ 'community' => '65518:1' }], 'name' => 'aggregated' }]
      ]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'added community-set' do
      d_node = @cs_nodes[0].diff(@cs_nodes[4])
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [
        ['+', 'community-set[1]', { 'communities' => [{ 'community' => '65518:2' }], 'name' => 'testing' }]
      ]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'deleted community-set' do
      d_node = @cs_nodes[4].diff(@cs_nodes[0])
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [
        ['-', 'community-set[1]', { 'communities' => [{ 'community' => '65518:2' }], 'name' => 'testing' }]
      ]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end
  end
end
