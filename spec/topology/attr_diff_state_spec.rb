# frozen_string_literal: true

# diff-state restoring of attributes and supports (data of diff output -> Networks -> data)
RSpec.describe 'diff state of attribute and support' do
  let(:attr_diff_state) do
    { 'forward' => 'changed', 'backward' => nil, 'pair' => 'attribute',
      'diff_data' => [{ 'path' => 'node-type', 'type' => 'changed' }] }
  end
  let(:support_diff_state) { { 'forward' => 'kept', 'backward' => nil, 'pair' => 'support' } }
  let(:topo_data) do
    { 'ietf-network:networks' => { 'network' => [{
      'network-id' => 'nw1', 'network-types' => { 'mddo-topology:l3-network' => {} },
      'node' => [{
        'node-id' => 'n1',
        'supporting-node' => [{ 'network-ref' => 'nw0', 'node-ref' => 'n0', '_diff_state_' => support_diff_state }],
        'mddo-topology:l3-node-attributes' => { 'node-type' => 'node', '_diff_state_' => attr_diff_state },
        'ietf-network-topology:termination-point' => []
      }],
      'ietf-network-topology:link' => []
    }] } }
  end
  let(:node) { Netomox::Topology::Networks.new(topo_data).find_node('nw1', 'n1') }

  it 'restores diff state of the attribute' do
    state = node.attribute.diff_state
    expect([state.forward, state.backward, state.detect]).to eq [:changed, nil, :changed]
    expect(state.diff_data).to eq [{ 'path' => 'node-type', 'type' => 'changed' }]
  end

  it 'restores diff state of the support' do
    state = node.supports.first.diff_state
    expect(state.forward).to eq :kept
    expect(state.pair).to eq 'support'
  end

  it 'outputs the restored diff state as it is' do
    attr_data = node.attribute.to_data
    expect(attr_data['_diff_state_']).to eq(
      forward: :changed, backward: nil, pair: 'attribute', diff_data: [{ 'path' => 'node-type', 'type' => 'changed' }]
    )
    expect(node.supports.first.to_data['_diff_state_']).to include(pair: 'support')
  end

  it 'keeps the data of whole topology through Networks.new and #to_data' do
    data = Netomox::Topology::Networks.new(topo_data).to_data
    node_data = data['ietf-network:networks']['network'].first['node'].first
    expect(node_data['mddo-topology:l3-node-attributes']['_diff_state_']).to include(forward: :changed, pair: 'attribute')
  end

  it 'has the empty (kept) diff state without `_diff_state_` in the data' do
    topo_data['ietf-network:networks']['network'][0]['node'][0]['mddo-topology:l3-node-attributes'].delete('_diff_state_')
    state = node.attribute.diff_state
    expect(state.detect).to eq :kept
    expect(state.to_data).to eq({ forward: :kept, backward: nil, pair: '' })
  end
end
