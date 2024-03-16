# frozen_string_literal: true

RSpec.describe 'bgp-proc bgp-policy attribute', :attr, :bgp, :diff, :node do
  before do
    parent = lambda do |name|
      nws = Netomox::DSL::Networks.new
      Netomox::DSL::Network.new(nws, name) do
        type Netomox::NWTYPE_MDDO_BGP_PROC
      end
    end

    policies = []
    # policies[0]: original
    policies.push [
      {
        default: { actions: [{ target: 'reject' }] },
        name: 'ipv4-core',
        statements: [
          {
            actions: [
              { target: 'accept' },
              { community: { action: 'set', name: 'aggregated' } },
              { next_hop: '172.31.255.1' }
              # { local_preference: 300 },
              # { metric: 100 }
            ],
            conditions: [
              { protocol: 'bgp' },
              { rib: 'inet.0' },
              { route_filter: { prefix: '0.0.0.0/0', length: {}, match_type: 'exact' } }
              # { policy: 'reject-in-rule-ipv4' },
              # { as_path_group: 'asXXXXX-origin' },
              # { community: ['aggregated'] },
              # { prefix_list_filter: { prefix_list: 'default-ipv4', match_type: 'exact' } }
            ],
            if: 'if',
            name: 'bgp'
          }
        ]
      }
    ]
    additional_statement = {
      default: { actions: [{ target: 'accept' }] },
      name: 'test-statement',
      statements: [
        {
          actions: [{ target: 'accept' }],
          conditions: [{ protocol: 'bgp' }],
          if: 'if',
          name: 'hoge'
        }
      ]
    }

    # NOTE: define number of test patterns at first
    pattern_number = 7
    # deep copy
    pattern_number.times do
      policies.push(Marshal.load(Marshal.dump(policies[0])))
    end

    # policies[1]: same as original (policies[0])
    # policies[2]: changed statements[0] default statement
    policies[2][0][:default] = { actions: [{ metric: 110 }] }

    # policies[3]: changed statements[0] actions
    policies[3][0][:statements][0][:actions][2] = { local_preference: 300 }
    # policies[4]: added statements[0] actions
    policies[4][0][:statements][0][:actions].push({ metric: 200 })

    # policies[5]: changed statements[0] conditions
    policies[5][0][:statements][0][:conditions][1] = { policy: 'reject-in-rule-ipv4' }
    # policies[6]: added statements[0] conditions
    policies[6][0][:statements][0][:conditions].push({ as_path_group: 'asXXXXX-origin' })

    # policy[7]: added statements
    policies[7].push(additional_statement)

    # topology objects correspond with policies
    @bgp_proc_nodes = policies.map do |policy|
      node = Netomox::DSL::Node.new(parent.call('bgp_proc'), 'nodeX') do
        attribute(router_id: '10.0.0.1', policies: policy)
      end
      Netomox::Topology::Node.new(node.topo_data, '')
    end
  end

  it 'kept bgp policy attribute' do
    d_node = @bgp_proc_nodes[0].diff(@bgp_proc_nodes[1])
    expect(d_node.diff_state.detect).to eq :kept
    expect(d_node.attribute.diff_state.detect).to eq :kept
    dd_expected = []
    expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
  end

  it 'changed default statement' do
    d_node = @bgp_proc_nodes[0].diff(@bgp_proc_nodes[2])
    expect(d_node.diff_state.detect).to eq :changed
    expect(d_node.attribute.diff_state.detect).to eq :changed
    dd_expected = [
      ['-', 'policy[0].default.actions[0]', { 'target' => 'reject' }],
      ['+', 'policy[0].default.actions[0]', { 'metric' => 110 }]
    ]
    expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
  end

  context 'diff with actions in a statement' do
    it 'changed actions in statement' do
      d_node = @bgp_proc_nodes[0].diff(@bgp_proc_nodes[3])
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [
        ['-', 'policy[0].statements[0].actions[2]', { 'next-hop' => '172.31.255.1' }],
        ['+', 'policy[0].statements[0].actions[2]', { 'local-preference' => 300 }]
      ]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'added actions in statement' do
      d_node = @bgp_proc_nodes[0].diff(@bgp_proc_nodes[4])
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [
        ['+', 'policy[0].statements[0].actions[3]', { 'metric' => 200 }]
      ]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'deleted actions in statement' do
      d_node = @bgp_proc_nodes[4].diff(@bgp_proc_nodes[0])
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [
        ['-', 'policy[0].statements[0].actions[3]', { 'metric' => 200 }]
      ]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end
  end

  context 'diff with conditions in a statement' do
    it 'changed conditions in statement' do
      d_node = @bgp_proc_nodes[0].diff(@bgp_proc_nodes[5])
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [
        ['-', 'policy[0].statements[0].conditions[1]', { 'rib' => 'inet.0' }],
        ['+', 'policy[0].statements[0].conditions[1]', { 'policy' => 'reject-in-rule-ipv4' }]
      ]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'added actions in statement' do
      d_node = @bgp_proc_nodes[0].diff(@bgp_proc_nodes[6])
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [
        ['+', 'policy[0].statements[0].conditions[3]', { 'as-path-group' => 'asXXXXX-origin' }]
      ]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'deleted actions in statement' do
      d_node = @bgp_proc_nodes[6].diff(@bgp_proc_nodes[0])
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [
        ['-', 'policy[0].statements[0].conditions[3]', { 'as-path-group' => 'asXXXXX-origin' }]
      ]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end
  end

  context 'diff with statements' do
    it 'added a statement' do
      d_node = @bgp_proc_nodes[0].diff(@bgp_proc_nodes[7])
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [
        ['+',
         'policy[1]',
         { 'default' => { 'actions' => [{ 'target' => 'accept' }] },
           'name' => 'test-statement',
           'statements' =>
            [{ 'actions' => [{ 'target' => 'accept' }],
               'conditions' => [{ 'protocol' => 'bgp' }],
               'if' => 'if',
               'name' => 'hoge' }] }]
      ]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end

    it 'deleted a statement' do
      d_node = @bgp_proc_nodes[7].diff(@bgp_proc_nodes[0])
      expect(d_node.diff_state.detect).to eq :changed
      expect(d_node.attribute.diff_state.detect).to eq :changed
      dd_expected = [
        ['-',
         'policy[1]',
         { 'default' => { 'actions' => [{ 'target' => 'accept' }] },
           'name' => 'test-statement',
           'statements' =>
             [{ 'actions' => [{ 'target' => 'accept' }],
                'conditions' => [{ 'protocol' => 'bgp' }],
                'if' => 'if',
                'name' => 'hoge' }] }]
      ]
      expect(d_node.attribute.diff_state.diff_data).to eq dd_expected
    end
  end
end
