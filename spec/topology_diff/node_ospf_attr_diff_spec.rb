# frozen_string_literal: true

RSpec.describe 'node diff with ospf-area attribute', :attr, :diff, :node, :ospf_attr do
  before do
    parent = lambda do |name|
      nws = Netomox::DSL::Networks.new
      Netomox::DSL::Network.new(nws, name) do
        type Netomox::NWTYPE_MDDO_OSPF_AREA
      end
    end

    attr1 = {
      node_type: 'ospf_proc',
      router_id: '192.168.0.1',
      redistribute_list: [
        { protocol: 'static', metric_type: 2 }
      ]
    }
    attr2 = {
      node_type: 'ospf_proc',
      router_id: '192.168.0.2', # change
      redistribute_list: [
        { protocol: 'static', metric_type: 2 }
      ]
    }
    attr3 = {
      node_type: 'ospf_proc',
      router_id: '192.168.0.1',
      redistribute_list: [
        { protocol: 'static', metric_type: 1 } # change internal
      ]
    }
    attr4 = {
      node_type: 'ospf_proc',
      router_id: '192.168.0.2', # change
      redistribute_list: [
        { protocol: 'static', metric_type: 2 },
        { protocol: 'connected', metric_type: 2 } # added internal
      ]
    }

    node_ospf_attr_empty = Netomox::DSL::Node.new(parent.call('ospf'), 'nodeX')
    node_ospf_attr1 = Netomox::DSL::Node.new(parent.call('ospf'), 'nodeX') do
      attribute(attr1)
    end
    node_ospf_attr2 = Netomox::DSL::Node.new(parent.call('ospf'), 'nodeX') do
      attribute(attr2)
    end
    node_ospf_attr3 = Netomox::DSL::Node.new(parent.call('ospf'), 'nodeX') do
      attribute(attr3)
    end
    node_ospf_attr4 = Netomox::DSL::Node.new(parent.call('ospf'), 'nodeX') do
      attribute(attr4)
    end

    @node_ospf_attr_empty = Netomox::Topology::Node.new(node_ospf_attr_empty.topo_data, '')
    @node_ospf_attr1 = Netomox::Topology::Node.new(node_ospf_attr1.topo_data, '')
    @node_ospf_attr2 = Netomox::Topology::Node.new(node_ospf_attr2.topo_data, '')
    @node_ospf_attr3 = Netomox::Topology::Node.new(node_ospf_attr3.topo_data, '')
    @node_ospf_attr4 = Netomox::Topology::Node.new(node_ospf_attr4.topo_data, '')
  end

  it 'kept ospf attribute' do
    d_node = @node_ospf_attr1.diff(@node_ospf_attr1.dup)
    expect(d_node.diff_state.detect).to eq :kept
    expect(d_node.attribute.diff_state.detect).to eq :kept
    dd_expected = []
    expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
  end

  context 'diff with no-attribute node' do
    it 'added whole ospf attribute' do
      d_node = @node_ospf_attr_empty.diff(@node_ospf_attr1)
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :added
      dd_expected = [
        ['+', '_diff_state_', { backward: nil, forward: :kept, pair: '' }],
        ['+', 'flag', []],
        ['+', 'log-adjacency-change', false],
        ['+', 'node-type', 'ospf_proc'],
        ['+', 'process-id', 'default'],
        ['+', 'redistribute', [{ 'metric-type' => 2, 'protocol' => 'static' }]],
        ['+', 'router-id', '192.168.0.1'],
        ['+', 'router-id-source', 'static']
      ]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'deleted whole ospf attribute' do
      d_node = @node_ospf_attr1.diff(@node_ospf_attr_empty)
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :deleted
      dd_expected = [
        ['-', '_diff_state_', { backward: nil, forward: :kept, pair: '' }],
        ['-', 'flag', []],
        ['-', 'log-adjacency-change', false],
        ['-', 'node-type', 'ospf_proc'],
        ['-', 'process-id', 'default'],
        ['-', 'redistribute', [{ 'metric-type' => 2, 'protocol' => 'static' }]],
        ['-', 'router-id', '192.168.0.1'],
        ['-', 'router-id-source', 'static']
      ]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end
  end

  context 'diff with sub-attribute of node attribute' do
    it 'changed a literal attribute' do
      d_node = @node_ospf_attr1.diff(@node_ospf_attr2)
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [%w[~ router-id 192.168.0.1 192.168.0.2]]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'changed a sub-attribute' do
      d_node = @node_ospf_attr1.diff(@node_ospf_attr3)
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [
        ['-', 'redistribute[0]', { 'protocol' => 'static', 'metric-type' => 2 }],
        ['+', 'redistribute[0]', { 'protocol' => 'static', 'metric-type' => 1 }]
      ]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'added a sub-attribute' do
      d_node = @node_ospf_attr1.diff(@node_ospf_attr4)
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [
        ['+', 'redistribute[1]', { 'protocol' => 'connected', 'metric-type' => 2 }],
        ['~', 'router-id', '192.168.0.1', '192.168.0.2']
      ]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'deleted a sub-attribute' do
      d_node = @node_ospf_attr4.diff(@node_ospf_attr1)
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
    end
  end
end
