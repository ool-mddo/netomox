# frozen_string_literal: true

RSpec.describe 'check DSL L3 firewall policy rule (application/address are arrays)', :dsl, :firewall, :mddo do
  it 'keeps arrays as they are' do
    rule = Netomox::DSL::MddoL3FirewallPolicyRule.new(
      name: 'r', action: 'permit', application: %w[junos-ping junos-https],
      source_address: %w[a b], destination_address: ['any']
    )
    expect(rule.topo_data).to eq(
      'name' => 'r', 'action' => 'permit', 'application' => %w[junos-ping junos-https],
      'source_address' => %w[a b], 'destination_address' => ['any']
    )
  end

  it 'converts String to a single-element array' do
    rule = Netomox::DSL::MddoL3FirewallPolicyRule.new(application: 'any', source_address: 'any',
                                                      destination_address: 'any')
    expect(rule.topo_data.values_at('application', 'source_address', 'destination_address')).to eq [['any']] * 3
  end

  it 'converts empty string and default to an empty array' do
    rule = Netomox::DSL::MddoL3FirewallPolicyRule.new(application: '')
    expect(rule.topo_data.values_at('application', 'source_address', 'destination_address')).to eq [[]] * 3
  end

  it 'does not share arrays between instances (default value and input data)' do
    first = Netomox::DSL::MddoL3FirewallPolicyRule.new(name: 'a')
    first.application << 'modified'
    expect(Netomox::DSL::MddoL3FirewallPolicyRule.new(name: 'b').application).to eq []

    input = ['any']
    rule = Netomox::DSL::MddoL3FirewallPolicyRule.new(application: input)
    rule.application << 'modified'
    expect(input).to eq ['any']
  end
end
