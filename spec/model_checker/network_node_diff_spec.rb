require_relative '../spec_helper'

describe 'network diff (nw list)', :diff, :network, :nw do
  context 'when nw list changed' do
    before do
      nw_node0_def = NWTopoDSL::Network.new('nwX')
      nw_node1_def = NWTopoDSL::Network.new('nwX') do
        node 'node1'
      end
      nw_node2_def = NWTopoDSL::Network.new('nwX') do
        node 'node1'
        node 'node2'
      end
      nw_node2_changed_def = NWTopoDSL::Network.new('nwX') do
        node 'node1'
        node 'node2xx'
      end
      @nw_node0 = TopoChecker::Network.new(nw_node0_def.topo_data)
      @nw_node1 = TopoChecker::Network.new(nw_node1_def.topo_data)
      @nw_node2 = TopoChecker::Network.new(nw_node2_def.topo_data)
      @nw_node2_changed = TopoChecker::Network.new(nw_node2_changed_def.topo_data)
    end

    context '0 to N, N to 0' do
      it 'added nw node (0 -> 1)' do
        d_nw = @nw_node0.diff(@nw_node1)
        expect(d_nw.diff_state.detect).to eq :changed
        list = d_nw.nodes.map { |t| t.diff_state.detect }
        expect(list.sort).to eq %i[added]
      end

      it 'deleted nw node (1 -> 0)' do
        d_nw = @nw_node1.diff(@nw_node0)
        expect(d_nw.diff_state.detect).to eq :changed
        list = d_nw.nodes.map { |t| t.diff_state.detect }
        expect(list.sort).to eq %i[deleted]
      end
    end

    context 'N to M, M to N' do
      it 'added nw node (1 -> 2)' do
        d_nw = @nw_node1.diff(@nw_node2)
        expect(d_nw.diff_state.detect).to eq :changed
        list = d_nw.nodes.map { |t| t.diff_state.detect }
        expect(list.sort).to eq %i[added kept]
      end

      it 'added nw node (1 -> 2)' do
        d_nw = @nw_node2.diff(@nw_node1)
        expect(d_nw.diff_state.detect).to eq :changed
        list = d_nw.nodes.map { |t| t.diff_state.detect }
        expect(list.sort).to eq %i[deleted kept]
      end
    end

    it 'changed nw node' do
      d_nw = @nw_node2.diff(@nw_node2_changed)
      expect(d_nw.diff_state.detect).to eq :changed
      list = d_nw.nodes.map { |t| t.diff_state.detect }
      expect(list.sort).to eq %i[added deleted kept]
    end
  end
end
