# frozen_string_literal: true

RSpec.describe 'check attribute conversion functions' do
  # rubocop:disable RSpec/ExampleLength
  it 'can convert topology-attribute to dsl-attribute' do
    origin_attr = {
      router_id: '10.0.0.1',
      confederation_id: 65_531,
      confederation_members: [65_532],
      peer_groups: [],
      route_reflector: false,
      policies: [
        {
          default: { actions: [{ target: 'reject' }] },
          name: 'ipv4-core',
          statements: [
            {
              actions: [{ target: 'accept' }],
              conditions: [{ protocol: 'bgp' }],
              if: 'if',
              name: 'bgp'
            }
          ]
        }
      ],
      prefix_sets: [{ name: 'default-ipv4', prefixes: [{ prefix: '0.0.0.0/0' }] }],
      as_path_sets: [{ group_name: 'any', as_path: [{ name: 'any', pattern: '.*' }] }],
      community_sets: [{ communities: [{ community: '65518:1' }], name: 'aggregated' }],
      redistribute_list: [], # TBA
      flags: %w[foo bar]
    }
    nws = Netomox::DSL::Networks.new do
      network 'bgp_proc' do
        type Netomox::NWTYPE_MDDO_BGP_PROC
        node 'node1' do
          attribute(origin_attr)
        end
      end
    end
    topo_data = nws.topo_data # RFC8345 json data

    nws = Netomox::Topology::Networks.new(topo_data)
    node = nws.find_network('bgp_proc')&.find_node_by_name('node1')
    converted_attr = Netomox.convert_attr_topo2dsl(node.attribute.to_data)
    expect(converted_attr).to eq origin_attr
  end
  # rubocop:enable RSpec/ExampleLength
end
