# frozen_string_literal: true

RSpec.describe 'check networks (top level container) attribute for MDDO', :attr, :networks do
  let(:nws_key) { "#{Netomox::NS_NW}:networks" }
  let(:attr_key) { "#{Netomox::NS_MDDO}:networks-attributes" }
  let(:flags) { %w[blueprint=original_asis_blueprint1 foo] }

  it 'outputs the attribute from DSL' do
    nws = Netomox::DSL::Networks.new do
      attribute(flags: %w[blueprint=bp1 foo])
      network 'nw1'
    end
    data = nws.topo_data
    expect(data[nws_key][attr_key]).to eq({ 'flag' => %w[blueprint=bp1 foo] })
    expect(data[nws_key]['network'].length).to eq 1
  end

  it 'does not output the attribute from DSL when it is not set or empty' do
    expect(Netomox::DSL::Networks.new.topo_data[nws_key]).to eq({ 'network' => [] })
    nws = Netomox::DSL::Networks.new { attribute(flags: []) }
    expect(nws.topo_data[nws_key]).to eq({ 'network' => [] })
  end

  it 'reads the attribute and round-trips it with Topology::Networks' do
    dsl_data = Netomox::DSL::Networks.new do
      attribute(flags: %w[blueprint=bp1])
      network 'nw1'
    end.topo_data
    nws = Netomox::Topology::Networks.new(dsl_data)
    expect(nws.attribute).to be_a Netomox::Topology::MddoNetworksAttribute
    expect(nws.attribute.flags).to eq %w[blueprint=bp1]
    expect(nws.to_data[nws_key][attr_key]['flag']).to eq %w[blueprint=bp1]
  end

  it 'does not output the attribute when the data has no attribute' do
    nws = Netomox::Topology::Networks.new(Netomox::DSL::Networks.new { network 'nw1' }.topo_data)
    expect(nws.attribute).to be_empty
    expect(nws.to_data[nws_key].key?(attr_key)).to be false
  end

  it 'passes the attribute through topo2dsl conversion and PseudoDSL#interpret' do
    dsl_data = Netomox::DSL::Networks.new do
      attribute(flags: %w[blueprint=bp1])
      network 'nw1'
    end.topo_data
    src = Netomox::Topology::Networks.new(dsl_data)

    pnws = Netomox::PseudoDSL::PNetworks.new
    pnws.attribute = Netomox.convert_attr_topo2dsl(src.attribute.to_data) unless src.attribute.empty?
    pnws.network('nw1')
    expect(pnws.attribute).to eq({ flags: %w[blueprint=bp1] })
    expect(pnws.interpret.topo_data[nws_key][attr_key]).to eq({ 'flag' => %w[blueprint=bp1] })
  end
end
