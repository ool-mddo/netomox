# frozen_string_literal: true

RSpec.describe 'check bgp-proc node bgp-policy attribute' do
  before do
    @default_diff_state = { backward: nil, forward: :kept, pair: '' }
  end

  # rubocop:disable RSpec/ExampleLength
  it 'generate bgp-policy actions' do
    as_path_sets = [
      { group_name: 'hoge', as_path: [{ name: '01', pattern: '65001+' }, { name: 'any', pattern: '.*' }] }
    ]
    policies = [
      {
        default: { actions: [{ target: 'reject' }] },
        name: 'ipv4-core',
        statements: [
          {
            actions: [
              { apply: 'reject-in-ipv4' },
              { target: 'accept' },
              { community: { action: 'set', name: 'aggregated' } },
              { next_hop: '172.31.255.1' },
              # to test Netomox::Topology::MddoBgpPolicyAction
              { unknown_bgp_action_key: 'unknown_value' },
              # accept both Integer and String number
              { local_preference: 300 },
              { local_preference: '310' },
              # accept both Integer and String number
              { metric: 100 },
              { metric: '110' },
              {
                as_path_prepend: [
                  # asn and repeat accept both Integer and String number
                  { asn: 65_001, repeat: '1' },
                  { asn: '65001', repeat: 1 },
                  { asn: 65_002, repeat: 2 }
                ]
              }
            ],
            conditions: [
              { protocol: 'bgp' },
              { rib: 'inet.0' },
              { route_filter: { prefix: '0.0.0.0/0', length: {}, match_type: 'exact' } },
              # accept both Integer and String number
              { route_filter: { prefix: '0.0.0.0/0', length: { min: 32, max: '25' }, match_type: 'exact' } },
              # to test Netomox::Topology::MddoBgpPolicyAction
              { unknown_bgp_condition_key: 'unknown_condition' },
              { policy: 'reject-in-rule-ipv4' },
              { as_path_group: 'asXXXXX-origin' },
              { community: ['aggregated'] },
              { prefix_list: 'asXXXXX-adv-ipv4' },
              { prefix_list_filter: { prefix_list: 'default-ipv4', match_type: 'exact' } }
            ],
            # with-if
            if: 'if',
            name: 'bgp'
          },
          {
            actions: [
              { target: 'accept' }
            ],
            conditions: [
              { protocol: 'bgp' }
            ],
            # without-if
            name: 'test-statement'
          }
        ]
      }
    ]

    orig_nws = Netomox::DSL::Networks.new do
      network 'bgp_proc' do
        type Netomox::NWTYPE_MDDO_BGP_PROC
        node 'node1' do
          attr = {
            router_id: '10.0.0.1',
            as_path_sets: as_path_sets,
            policies: policies
          }
          attribute(attr)
        end
      end
    end
    topo_data = orig_nws.topo_data
    target_nws = Netomox::Topology::Networks.new(topo_data)
    attr = target_nws.find_network('bgp_proc')&.find_node_by_name('node1')&.attribute

    expected_as_path_sets = [
      {
        'group-name' => 'hoge',
        'as-path' => [
          { 'name' => '01', 'pattern' => '65001+' },
          { 'name' => 'any', 'pattern' => '.*' }
        ]
      }
    ]
    expected_policies = [
      {
        'default' => {
          'actions' => [{ 'target' => 'reject' }]
        },
        'name' => 'ipv4-core',
        'statements' => [
          {
            'actions' => [
              { 'apply' => 'reject-in-ipv4' },
              { 'target' => 'accept' },
              { 'community' => { 'action' => 'set', 'name' => 'aggregated' } },
              { 'next-hop' => '172.31.255.1' },
              # skip unknown-bgp-action-key and continue next token
              { 'local-preference' => 300 },
              { 'local-preference' => 310 },
              { 'metric' => 100 },
              { 'metric' => 110 },
              {
                'as-path-prepend' => [
                  { 'asn' => 65_001, 'repeat' => 1 },
                  { 'asn' => 65_001, 'repeat' => 1 },
                  { 'asn' => 65_002, 'repeat' => 2 }
                ]
              }
            ],
            'conditions' => [
              { 'protocol' => 'bgp' },
              { 'rib' => 'inet.0' },
              { 'route-filter' => { 'prefix' => '0.0.0.0/0', 'length' => {}, 'match-type' => 'exact' } },
              { 'route-filter' => { 'prefix' => '0.0.0.0/0', 'length' => { 'min' => 32, 'max' => 25 }, 'match-type' => 'exact' } },
              # skip unknown-bgp-condition-key and continue next token
              { 'policy' => 'reject-in-rule-ipv4' },
              { 'as-path-group' => 'asXXXXX-origin' },
              { 'community' => ['aggregated'] },
              { 'prefix-list' => 'asXXXXX-adv-ipv4' },
              { 'prefix-list-filter' => { 'prefix-list' => 'default-ipv4', 'match-type' => 'exact' } }
            ],
            'if' => 'if',
            'name' => 'bgp'
          },
          {
            'actions' => [
              { 'target' => 'accept' }
            ],
            'conditions' => [
              { 'protocol' => 'bgp' }
            ],
            'name' => 'test-statement'
          }
        ]
      }
    ]
    expected_attr = {
      '_diff_state_' => @default_diff_state,
      'router-id' => '10.0.0.1',
      'confederation-id' => -1,
      'confederation-member' => [],
      'route-reflector' => false,
      'peer-group' => [],
      'policy' => expected_policies,
      'prefix-set' => [],
      'as-path-set' => expected_as_path_sets,
      'community-set' => [],
      'redistribute' => [],
      'flag' => []
    }
    expect(attr&.to_data).to eq expected_attr
  end
  # rubocop:enable RSpec/ExampleLength
end
