# frozen_string_literal: true

RSpec.describe 'DiffState (restored from data)' do
  describe '.from_data' do
    it 'converts forward/backward to symbols' do
      state = Netomox::Topology::DiffState.from_data({ 'forward' => 'added', 'backward' => 'kept', 'pair' => '' })
      expect([state.forward, state.backward]).to eq %i[added kept]
    end

    it 'accepts nil backward and missing diff_data' do
      state = Netomox::Topology::DiffState.from_data({ 'forward' => 'kept', 'backward' => nil, 'pair' => '' })
      expect(state.backward).to be_nil
      expect(state.diff_data).to be_nil
    end
  end

  describe '#to_data and #to_s with a pair path string (restored from data)' do
    let(:state) { Netomox::Topology::DiffState.new(forward: :changed, pair: 'ospf_area0__rt4') }

    it 'outputs the path string as pair' do
      expect(state.to_data[:pair]).to eq 'ospf_area0__rt4'
    end

    it 'can be converted to string' do
      expect(state.to_s).to include('pair:ospf_area0__rt4')
    end
  end

  describe '#to_data with a pair object (made by diff)' do
    it 'outputs the path of the counter-part object' do
      pair = instance_double(Netomox::Topology::Node, path: 'nw1__n1', name: 'n1', empty?: false)
      expect(Netomox::Topology::DiffState.new(forward: :changed, pair: pair).to_data[:pair]).to eq 'nw1__n1'
    end
  end
end
