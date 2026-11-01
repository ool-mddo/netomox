# frozen_string_literal: true

RSpec.describe 'check L3 firewall policy rule (application/address are arrays)' do
  def rule_data(overrides = {})
    { 'name' => 'PERMIT-PING-DNS-HTTPS', 'action' => 'permit',
      'application' => ['any'], 'source_address' => ['any'], 'destination_address' => ['any'] }.merge(overrides)
  end

  def build_rule(data)
    Netomox::Topology::MddoL3FirewallPolicyRule.new(data, 'rules')
  end

  it 'keeps multiple values and round-trips them without error log' do
    apps = %w[junos-ping junos-dns-udp junos-dns-tcp junos-http junos-https]
    data = rule_data('application' => apps, 'source_address' => %w[host-a host-b])
    expect(Netomox.logger).not_to receive(:error)
    rule = build_rule(data)
    expect(rule.application).to eq apps
    expect(rule.to_data).to eq data
  end

  it 'converts legacy String values to single-element arrays' do
    rule = build_rule(rule_data('application' => 'any', 'source_address' => 'any', 'destination_address' => 'any'))
    expect(rule.to_data).to eq rule_data
  end

  it 'converts empty string to an empty array' do
    rule = build_rule(rule_data('application' => ''))
    expect(rule.application).to eq []
  end

  it 'uses empty arrays when keys are not specified' do
    rule = build_rule({ 'name' => 'r', 'action' => 'permit' })
    expect([rule.application, rule.source_address, rule.destination_address]).to eq [[], [], []]
  end

  it 'distinguishes rules by array contents' do
    expect(build_rule(rule_data)).not_to eq build_rule(rule_data('application' => %w[a b]))
  end

  it 'does not share arrays between instances (default value and input data)' do
    first = build_rule({ 'name' => 'a' })
    first.application << 'modified'
    expect(build_rule({ 'name' => 'b' }).application).to eq []

    data = rule_data
    rule = build_rule(data)
    rule.application << 'modified'
    expect(data['application']).to eq ['any']
  end
end
