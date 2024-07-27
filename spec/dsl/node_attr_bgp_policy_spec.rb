# frozen_string_literal: true

RSpec.describe 'node bgp-policy attribute dsl', :dsl, :mddo, :node do
  before do
    nws = Netomox::DSL::Networks.new do
      network 'test-bgp-proc' do
        type Netomox::NWTYPE_MDDO_BGP_PROC
      end
    end
    @tp_key = "#{Netomox::NS_TOPO}:termination-point"
    @bgp_proc_nw = nws.network('test-bgp-proc')
    @bgp_proc_attr_key = "#{Netomox::NS_MDDO}:bgp-proc-node-attributes"
  end

  it 'returns prefix-set', :attr, :bgp_attr do
    args = [
      { name: 'default-ipv4', prefixes: [{ prefix: '0.0.0.0/0' }] },
      { name: 'aggregated-ipv4', prefixes: [{ prefix: '10.100.0.0/16' }, { prefix: '10.110.0.0/16' }] }
    ]
    prefix_sets = args.map { |p| Netomox::DSL::MddoBgpPrefixSet.new(**p) }
    prefix_sets_data = [
      { 'name' => 'default-ipv4', 'prefixes' => [{ 'prefix' => '0.0.0.0/0' }] },
      { 'name' => 'aggregated-ipv4', 'prefixes' => [{ 'prefix' => '10.100.0.0/16' }, { 'prefix' => '10.110.0.0/16' }] }
    ]
    expect(prefix_sets.map(&:topo_data)).to eq prefix_sets_data
  end

  it 'returns bgp-as-path-set', :attr, :bgp_attr do
    args = [
      { group_name: 'aspath-longer200', as_path: { name: 'aspath-longer200', pattern: '.{200,}' } },
      { group_name: 'any', as_path: { name: 'any', pattern: '.*' } }
    ]
    as_path_set = args.map { |a| Netomox::DSL::MddoBgpAsPathSet.new(**a) }
    as_path_set_data = [
      { 'group-name' => 'aspath-longer200', 'as-path' => { 'name' => 'aspath-longer200', 'pattern' => '.{200,}' } },
      { 'group-name' => 'any', 'as-path' => { 'name' => 'any', 'pattern' => '.*' } }
    ]
    expect(as_path_set.map(&:topo_data)).to eq as_path_set_data
  end

  it 'returns bgp-community-set', :attr, :bgp_attr do
    args = [
      { name: 'aggregated', communities: [{ community: '65518:1' }] },
      { name: 'any', communities: [{ community: '"":""' }] },
      { name: 'peer', communities: [{ community: '65518:2' }] }
    ]
    community_sets = args.map { |c| Netomox::DSL::MddoBgpCommunitySet.new(**c) }
    community_sets_data = [
      { 'name' => 'aggregated', 'communities' => [{ 'community' => '65518:1' }] },
      { 'name' => 'any', 'communities' => [{ 'community' => '"":""' }] },
      { 'name' => 'peer', 'communities' => [{ 'community' => '65518:2' }] }
    ]
    expect(community_sets.map(&:topo_data)).to eq community_sets_data
  end

  it 'returns bgp-policy-condition-route-filter-length', :attr, :bgp_attr do
    rfl = Netomox::DSL::BgpPolicyConditionRFLength.new(min: 32, max: 25)
    rfl_data = { 'min' => 32, 'max' => 25 }
    expect(rfl.topo_data).to eq rfl_data
  end

  it 'returns bgp-policy-condition-route-filter-length (default)', :attr, :bgp_attr do
    rfl = Netomox::DSL::BgpPolicyConditionRFLength.new
    rfl_data = {}
    expect(rfl.topo_data).to eq rfl_data
  end

  it 'returns bgp-policy-prefix-list-filter', :attr, :bgp_attr do
    plf = Netomox::DSL::MddoBgpPolicyConditionPrefixListFilter.new(prefix_list: 'default-ipv4', match_type: 'exact')
    pfl_data = { 'prefix-list' => 'default-ipv4', 'match-type' => 'exact' }
    expect(plf.topo_data).to eq pfl_data
  end

  it 'returns bgp-policy-condition-route-filter (prefix-length-range)', :attr, :bgp_attr do
    args = { length: { max: 32, min: 25 }, match_type: 'prefix-length-range', prefix: '0.0.0.0/0' }
    crf = Netomox::DSL::MddoBgpPolicyConditionRouteFilter.new(**args)
    crf_data = {
      'length' => { 'max' => 32, 'min' => 25 },
      'prefix' => '0.0.0.0/0',
      'match-type' => 'prefix-length-range'
    }
    expect(crf.topo_data).to eq crf_data
  end

  it 'returns bgp-policy-condition-route-filter (exact-1)', :attr, :bgp_attr do
    args = { match_type: 'exact', prefix: '10.120.0.0/17' }
    crf = Netomox::DSL::MddoBgpPolicyConditionRouteFilter.new(**args)
    crf_data = {
      'length' => {},
      'prefix' => '10.120.0.0/17',
      'match-type' => 'exact'
    }
    expect(crf.topo_data).to eq crf_data
  end

  it 'returns bgp-policy-condition-route-filter (exact-2)', :attr, :bgp_attr do
    args = { length: { max: 16, min: 16 }, match_type: 'exact', prefix: '10.100.0.0/16' }
    crf = Netomox::DSL::MddoBgpPolicyConditionRouteFilter.new(**args)
    crf_data = {
      'length' => { 'max' => 16, 'min' => 16 },
      'prefix' => '10.100.0.0/16',
      'match-type' => 'exact'
    }
    expect(crf.topo_data).to eq crf_data
  end

  it 'returns bgp-policy-action-community', :attr, :bgp_attr do
    ac = Netomox::DSL::MddoBgpPolicyActionCommunity.new(action: 'set', name: 'aggregated')
    ac_data = { 'action' => 'set', 'name' => 'aggregated' }
    expect(ac.topo_data).to eq ac_data
  end

  it 'returns bgp-policy-condition', :attr, :bgp_attr do
    args = [
      { protocol: 'bgp' },
      { rib: 'inet.0' },
      { route_filter: { prefix: '0.0.0.0/0', length: {}, match_type: 'exact' } },
      { policy: 'reject-in-rule-ipv4' },
      { as_path_group: 'asXXXXX-origin' },
      { community: ['aggregated'] },
      { prefix_list: 'asXXXXX-adv-ipv4' },
      { prefix_list_filter: { prefix_list: 'default-ipv4', match_type: 'exact' } },
      { unknown_bgp_condition_key: 'unknown_condition' }
    ]
    conditions = args.map { |a| Netomox::DSL::MddoBgpPolicyCondition.new(**a) }
    conditions_data = [
      { 'protocol' => 'bgp' },
      { 'rib' => 'inet.0' },
      { 'route-filter' => { 'prefix' => '0.0.0.0/0', 'length' => {}, 'match-type' => 'exact' } },
      { 'policy' => 'reject-in-rule-ipv4' },
      { 'as-path-group' => 'asXXXXX-origin' },
      { 'community' => ['aggregated'] },
      { 'prefix-list' => 'asXXXXX-adv-ipv4' },
      { 'prefix-list-filter' => { 'prefix-list' => 'default-ipv4', 'match-type' => 'exact' } },
      { 'unknown-bgp-condition-key' => 'unknown_condition' } # to test Netomox::Topology::MddoBgpPolicyCondition
    ]
    expect(conditions.map(&:topo_data)).to eq conditions_data
  end

  it 'raises exception if unknown condition keyword' do
    key = :police
    arg = { key => 'reject-in-rule-ipv4' }
    expect do
      Netomox::DSL::MddoBgpPolicyCondition.new(**arg)
    end.to raise_error(Netomox::DSL::DSLInvalidArgumentError, "Unknown bgp-policy element keyword: #{key} in #{arg}")
  end

  # rubocop:disable RSpec/ExampleLength
  it 'returns bgp-policy-action', :attr, :bgp_attr do
    args = [
      { apply: 'reject-in-ipv4' },
      { target: 'accept' },
      { community: { action: 'set', name: 'aggregated' } },
      { next_hop: '172.31.255.1' },
      { local_preference: 300 },
      { metric: 100 },
      {
        as_path_prepend: [
          { asn: 65_001 }, # omit repeat key (default: 1)
          { asn: 65_001, repeat: 1 },
          { asn: 65_002, repeat: 2 },
          { asn: 65_003, repeat: 3 }
        ]
      },
      { unknown_bgp_action_key: 'unknown_value' } # to test Netomox::Topology::MddoBgpPolicyAction
    ]
    actions = args.map { |a| Netomox::DSL::MddoBgpPolicyAction.new(**a) }
    actions_data = [
      { 'apply' => 'reject-in-ipv4' },
      { 'target' => 'accept' },
      { 'community' => { 'action' => 'set', 'name' => 'aggregated' } },
      { 'next-hop' => '172.31.255.1' },
      { 'local-preference' => 300 },
      { 'metric' => 100 },
      {
        'as-path-prepend' => [
          { 'asn' => 65_001, 'repeat' => 1 },
          { 'asn' => 65_001, 'repeat' => 1 },
          { 'asn' => 65_002, 'repeat' => 2 },
          { 'asn' => 65_003, 'repeat' => 3 }
        ]
      },
      { 'unknown-bgp-action-key' => 'unknown_value' } # to test Netomox::Topology::MddoBgpPolicyAction
    ]
    expect(actions.map(&:topo_data)).to eq actions_data
  end
  # rubocop:enable RSpec/ExampleLength

  it 'raises exception if unknown action keyword' do
    key = :apple
    arg = { key => 'reject-in-ipv4' }
    expect do
      Netomox::DSL::MddoBgpPolicyAction.new(**arg)
    end.to raise_error(Netomox::DSL::DSLInvalidArgumentError, "Unknown bgp-policy element keyword: #{key} in #{arg}")
  end

  it 'returns bgp-policy-statement', :attr, :bgp_attr do
    args = [
      # without-if
      {
        name: '10',
        conditions: [{ policy: 'reject-in-rule-ipv4' }],
        actions: [{ target: 'reject' }]
      },
      # with-if
      {
        name: '20',
        if: 'if',
        conditions: [{ as_path_group: 'asXXXXX-origin' }],
        actions: [{ metric: 100 }, { target: 'accept' }]
      }
    ]
    statements = args.map { |a| Netomox::DSL::MddoBgpPolicyStatement.new(**a) }
    statements_data = [
      {
        'name' => '10',
        'conditions' => [{ 'policy' => 'reject-in-rule-ipv4' }],
        'actions' => [{ 'target' => 'reject' }]
      },
      {
        'name' => '20',
        'if' => 'if',
        'conditions' => [{ 'as-path-group' => 'asXXXXX-origin' }],
        'actions' => [{ 'metric' => 100 }, { 'target' => 'accept' }]
      }
    ]
    expect(statements.map(&:topo_data)).to eq statements_data
  end

  it 'returns bgp-policy', :attr, :bgp_attr do
    args = [
      {
        name: 'ipv4-core',
        default: { actions: [{ target: 'reject' }] },
        statements: []
      }
    ]
    policies = args.map { |p| Netomox::DSL::MddoBgpPolicy.new(**p) }
    policies_data = [
      {
        'name' => 'ipv4-core',
        'default' => { 'actions' => [{ 'target' => 'reject' }] },
        'statements' => []
      }
    ]
    expect(policies.map(&:topo_data)).to eq policies_data
  end

  # rubocop:disable RSpec/ExampleLength
  it 'generate node that has bgp-policy attribute', :attr, :bgp_attr do
    prefix_sets = [
      { name: 'default-ipv4', prefixes: [{ prefix: '0.0.0.0/0' }] }
    ]
    as_path_sets = [
      { group_name: 'any', as_path: { name: 'any', pattern: '.*' } }
    ]
    community_sets = [
      { communities: [{ community: '65518:1' }], name: 'aggregated' }
    ]
    policies = [
      {
        default: { actions: [{ target: 'reject' }] },
        name: 'ipv4-core',
        statements: [
          {
            actions: [{ target: 'accept' }],
            conditions: [{ protocol: 'bgp' }],
            if: 'if',
            name: 'bgp'
          },
          {
            actions: [
              { community: { action: 'set', name: 'aggregated' } },
              { next_hop: '172.31.255.1' },
              { target: 'accept' }
            ],
            conditions: [
              { protocol: 'static' },
              { rib: 'inet.0' },
              { route_filter: { length: {}, match_type: 'exact', prefix: '10.100.0.0/16' } }
            ],
            if: 'if',
            name: 'aggregated-static'
          }
        ]
      }
    ]
    node = Netomox::DSL::Node.new(@bgp_proc_nw, 'nodeX') do
      attr = {
        router_id: '192.168.255.2',
        prefix_sets: prefix_sets,
        as_path_sets: as_path_sets,
        community_sets: community_sets,
        policies: policies
      }
      attribute(attr)
    end

    prefix_set_data = [
      { 'name' => 'default-ipv4', 'prefixes' => [{ 'prefix' => '0.0.0.0/0' }] }
    ]
    as_path_set_data = [
      { 'group-name' => 'any', 'as-path' => { 'name' => 'any', 'pattern' => '.*' } }
    ]
    community_set_data = [
      { 'communities' => [{ 'community' => '65518:1' }], 'name' => 'aggregated' }
    ]
    policies_data = [
      {
        'default' => { 'actions' => [{ 'target' => 'reject' }] },
        'name' => 'ipv4-core',
        'statements' => [
          {
            'actions' => [{ 'target' => 'accept' }],
            'conditions' => [{ 'protocol' => 'bgp' }],
            'if' => 'if',
            'name' => 'bgp'
          },
          {
            'actions' => [
              { 'community' => { 'action' => 'set', 'name' => 'aggregated' } },
              { 'next-hop' => '172.31.255.1' },
              { 'target' => 'accept' }
            ],
            'conditions' => [
              { 'protocol' => 'static' },
              { 'rib' => 'inet.0' },
              { 'route-filter' => { 'length' => {}, 'match-type' => 'exact', 'prefix' => '10.100.0.0/16' } }
            ],
            'if' => 'if',
            'name' => 'aggregated-static'
          }
        ]
      }
    ]
    node_data = {
      'node-id' => 'nodeX',
      @tp_key => [],
      @bgp_proc_attr_key => {
        'router-id' => '192.168.255.2',
        'confederation-id' => -1,
        'confederation-member' => [],
        'route-reflector' => false,
        'peer-group' => [],
        'policy' => policies_data,
        'prefix-set' => prefix_set_data,
        'as-path-set' => as_path_set_data,
        'community-set' => community_set_data,
        'redistribute' => [],
        'flag' => []
      }
    }
    expect(node.topo_data).to eq node_data
  end
  # rubocop:enable RSpec/ExampleLength
end
