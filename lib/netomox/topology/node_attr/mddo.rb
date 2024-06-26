# frozen_string_literal: true

require 'netomox/topology/attr_base'
require 'netomox/topology/node_attr/base'
require 'netomox/topology/node_attr/mddo_l3_static_route'
require 'netomox/topology/node_attr/mddo_ospf_redistribute'
require 'netomox/topology/node_attr/mddo_bgp_policy'

module Netomox
  module Topology
    # attribute for L1 node
    class MddoL1NodeAttribute < AttributeBase
      # @!attribute [rw] os_type
      #   @return [String]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :os_type, :flags

      # Attribute definition of L1 node
      ATTR_DEFS = [
        { int: :os_type, ext: 'os-type', default: '' },
        { int: :flags, ext: 'flag', default: [] }
      ].freeze

      # @param [Hash] data Attribute data (MDDO)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "attribute: #{@name}"
      end
    end

    # attribute for L2 node
    class MddoL2NodeAttribute < AttributeBase
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] vlan_id
      #   @return [Integer]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :name, :vlan_id, :flags

      # Attribute definition of L2 node
      ATTR_DEFS = [
        { int: :name, ext: 'name', default: '' },
        { int: :vlan_id, ext: 'vlan-id', default: 0 },
        { int: :flags, ext: 'flag', default: [] }
      ].freeze

      # @param [Hash] data Attribute data (MDDO)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "attribute: #{@name}"
      end
    end

    # attribute for L3 node
    class MddoL3NodeAttribute < L3NodeAttributeBase
      # @!attribute [rw] node_type
      #   @return [String]
      # @!attribute [rw] static_routes
      #   @return []
      attr_accessor :node_type, :static_routes

      # Attribute definition of L3 node
      ATTR_DEFS = [
        { int: :node_type, ext: 'node-type', default: '' },
        { int: :static_routes, ext: 'static-route', default: [] }
      ].freeze

      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        @static_routes = convert_static_routes(data)
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [Array<L3Prefix>] Converted attribute data
      def convert_static_routes(data)
        key = @attr_table.ext_of(:static_routes)
        operative_array_key?(data, key) ? data[key].map { |s| MddoL3StaticRoute.new(s, key) } : []
      end
    end

    # attribute for ospf-area node
    class MddoOspfAreaNodeAttribute < AttributeBase
      # @!attribute [rw] node_type
      #   @return [String]
      # @!attribute [rw] router_id
      #   @return [String]
      #   @note dotted-quad string
      # @!attribute [rw] process_id
      #   @return [String]
      # @!attribute [rw] log_adjacency_change
      #   @return [Boolean]
      # @!attribute [rw] redistribute_list
      #   @return [Array<MddoOspfRedistribute>]
      # @!attribute [r] router_id_source
      #   @return [Symbol]
      #   @todo enum (:static, :auto)
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :node_type, :router_id, :process_id, :log_adjacency_change, :redistribute_list, :router_id_source,
                    :flags

      # Attribute definition of ospf-area node
      ATTR_DEFS = [
        { int: :node_type, ext: 'node-type', default: '' },
        { int: :router_id, ext: 'router-id', default: '' },
        { int: :process_id, ext: 'process-id', default: 'default' },
        { int: :log_adjacency_change, ext: 'log-adjacency-change', default: false },
        { int: :redistribute_list, ext: 'redistribute', default: [] },
        { int: :router_id_source, ext: 'router-id-source', default: 'dynamic' },
        { int: :flags, ext: 'flag', default: [] }
      ].freeze

      include Diffable

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        @redistribute_list = convert_redistribute_list(data)
      end

      # @return [String]
      def to_s
        "attribute: #{@router_id}"
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [Array<L3Prefix>] Converted attribute data
      def convert_redistribute_list(data)
        key = @attr_table.ext_of(:redistribute_list)
        operative_array_key?(data, key) ? data[key].map { |p| MddoOspfRedistribute.new(p, key) } : []
      end
    end

    # attribute for bgp-proc node
    class MddoBgpProcNodeAttribute < AttributeBase
      # @!attribute [rw] router_id
      #   @return [String]
      # @!attribute [rw] confederation_id
      #   @return [Integer] ASN
      # @!attribute [rw] confederation_members
      #   @return [Array<Integer>] List of ASN
      # @!attribute [rw] route_reflector
      #   @return [Boolean]
      # @!attribute [rw] peer_groups
      #   @return [Array] # TODO: attr implementation
      # @!attribute [rw] policies
      #   @return [Array<MddoBgpPolicy>]
      # @!attribute [rw] prefix_sets
      #   @return [Array<MddoBgpPrefixSet>]
      # @!attribute [rw] as_path_sets
      #   @return [Array<MddoBgpAsPathSet>]
      # @!attribute [rw] community_sets
      #   @return [Array<MddoBgpCommunitySet>]
      # @!attribute [rw] redistribute_list
      #   @return [Array] # TODO: attr implementation
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :router_id, :confederation_id, :confederation_members, :route_reflector, :peer_groups,
                    :policies, :prefix_sets, :as_path_sets, :community_sets, :redistribute_list, :flags

      # Attribute definition of bgp-proc node
      ATTR_DEFS = [
        { int: :router_id, ext: 'router-id', default: '' },
        { int: :confederation_id, ext: 'confederation-id', default: -1 },
        { int: :confederation_members, ext: 'confederation-member', default: [] },
        { int: :route_reflector, ext: 'route-reflector', default: false },
        { int: :peer_groups, ext: 'peer-group', default: [] },
        { int: :policies, ext: 'policy', default: [] },
        { int: :prefix_sets, ext: 'prefix-set', default: [] },
        { int: :as_path_sets, ext: 'as-path-set', default: [] },
        { int: :community_sets, ext: 'community-set', default: [] },
        { int: :redistribute_list, ext: 'redistribute', default: [] },
        { int: :flags, ext: 'flag', default: [] }
      ].freeze

      include Diffable

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)

        @policies = convert_policies(data)
        @prefix_sets = convert_prefix_sets(data)
        @as_path_sets = convert_as_path_sets(data)
        @community_sets = convert_community_sets(data)
      end

      # @return [String]
      def to_s
        "attribute: #{@router_id}"
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [Array<MddoBgpPolicy>] Converted attribute data
      def convert_policies(data)
        key = @attr_table.ext_of(:policies)
        operative_array_key?(data, key) ? data[key].map { |p| MddoBgpPolicy.new(p, key) } : []
      end

      # @param [Hash] data Attribute data (RFC8345)
      # @return [Array<MddoBgpPrefixSet>] Converted attribute data
      def convert_prefix_sets(data)
        key = @attr_table.ext_of(:prefix_sets)
        operative_array_key?(data, key) ? data[key].map { |p| MddoBgpPrefixSet.new(p, key) } : []
      end

      # @param [Hash] data Attribute data (RFC8345)
      # @return [Array<MddoBgpAsPathSet>] Converted attribute data
      def convert_as_path_sets(data)
        key = @attr_table.ext_of(:as_path_sets)
        operative_array_key?(data, key) ? data[key].map { |p| MddoBgpAsPathSet.new(p, key) } : []
      end

      # @param [Hash] data Attribute data (RFC8345)
      # @return [Array<MddoBgpCommunitySet>] Converted attribute data
      def convert_community_sets(data)
        key = @attr_table.ext_of(:community_sets)
        operative_array_key?(data, key) ? data[key].map { |p| MddoBgpCommunitySet.new(p, key) } : []
      end
    end

    # attribute for bgp-as node
    class MddoBgpAsNodeAttribute < AttributeBase
      # @!attribute [rw] as_number
      #   @return [Integer] AS number
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :as_number, :flags

      # Attribute definition of bgp-as node
      ATTR_DEFS = [
        { int: :as_number, ext: 'as-number', default: -1 },
        { int: :flags, ext: 'flag', default: [] }
      ].freeze

      include Diffable

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "attribute: #{@as_number}"
      end
    end
  end
end
