# frozen_string_literal: true

# Network Topology Modeling Toolbox
# functions and constants converting attributes in topology json to attributes for DSL(PseudoDSL).
module Netomox
  # Target Network Types
  UPPER_LAYER3_NWTYPE_LIST = [
    Netomox::NWTYPE_MDDO_L3,
    Netomox::NWTYPE_MDDO_OSPF_AREA,
    Netomox::NWTYPE_MDDO_BGP_PROC,
    Netomox::NWTYPE_MDDO_BGP_AS
  ].freeze

  # Table of the keys which can not convert standard way (exceptional keys in L3/OSPF network)
  # Netomox::Topology attribute (object/external-key) -> Netomox::PseudoDSL attribute (Simple Hash/internal-key)
  # NOTE: these keys are a list excepting `ip_addr`/`ip_address`
  PLURAL_ATTR_KEY_TABLE = {
    # plural + abbreviation key
    ip_address: :ip_addrs,
    # plural keys
    static_route: :static_routes,
    neighbor: :neighbors,
    prefix: :prefixes,
    flag: :flags,
    confederation_member: :confederation_members,
    peer_group: :peer_groups,
    policy: :policies,
    prefix_set: :prefix_sets,
    as_path_set: :as_path_sets,
    community_set: :community_sets,
    import_policy: :import_policies,
    export_policy: :export_policies,
    redistribute: :redistribute_list
  }.freeze

  # Attribute to pass-through its value
  PASS_THROUGH_ATTR_INT_KEYS = %i[].freeze

  module_function

  # @param [Symbol] key Key to convert
  # @param [Array, Object] value
  # @return [Symbol] Converted key
  def convert_key_ext_to_int(key, value)
    # convert key symbol (external key like 'os-type') to snake_case symbol (:os_type)
    converted_key = key.to_s.tr('-', '_').to_sym
    return PLURAL_ATTR_KEY_TABLE[converted_key] if value.is_a?(Array) && PLURAL_ATTR_KEY_TABLE.key?(converted_key)

    # NOTE: irregular
    return :ip_addr if converted_key == :ip_address

    converted_key
  end

  # rubocop:disable Metrics/CyclomaticComplexity

  # Convert attributes in Netomox::Topology object to Netomox::PseudoDSL object
  # @param [Hash,Array,Object] value Hash data to convert its key symbol
  # @return [Hash,Array,Object] converted hash
  def convert_attr_topo2dsl(value)
    case value
    when Array
      value.map { |v| convert_attr_topo2dsl(v) }
    when Hash
      value.delete('_diff_state_') if value.key?('_diff_state_')
      value.delete('router-id-source') if value.key?('router-id-source')
      value.to_h do |k, v|
        int_key = convert_key_ext_to_int(k, v)
        [int_key, PASS_THROUGH_ATTR_INT_KEYS.include?(int_key) ? v : convert_attr_topo2dsl(v)]
      end
    else
      value
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
end
