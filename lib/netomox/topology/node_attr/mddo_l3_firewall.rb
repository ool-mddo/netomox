# frozen_string_literal: true

require 'netomox/topology/attr_base'
require 'netomox/topology/node_attr/mddo_l3_firewall_cluster_pair'
require 'netomox/topology/node_attr/mddo_l3_firewall_zone'
require 'netomox/topology/node_attr/mddo_l3_firewall_policy'

module Netomox
  module Topology
    # Firewall attribute container for L3 node attribute
    class MddoL3Firewall < SubAttributeBase
      # @!attribute [rw] node
      #   @return [String]
      # @!attribute [rw] pair
      #   @return [Hash] HA cluster pair (primary/secondary), stored as raw hash
      # @!attribute [rw] zones
      #   @return [Array<MddoL3FirewallZone>]
      # @!attribute [rw] policies
      #   @return [Array<MddoL3FirewallPolicy>]
      attr_accessor :node, :pair, :zones, :policies

      ATTR_DEFS = [
        { int: :node, ext: 'node', default: '' },
        { int: :pair, ext: 'pair', default: {} },
        { int: :zones, ext: 'zones', default: [] },
        { int: :policies, ext: 'policies', default: [] }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        @node = data['node'] || ''
        @pair = data['pair'] || {}
        @zones = convert_zones(data)
        @policies = convert_policies(data)
      end

      def empty?
        @node.empty? && @pair.empty? && @zones.empty? && @policies.empty?
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [Array<MddoL3FirewallZone>]
      def convert_zones(data)
        key = @attr_table.ext_of(:zones)
        operative_array_key?(data, key) ? data[key].map { |z| MddoL3FirewallZone.new(z, key) } : []
      end

      # @param [Hash] data Attribute data (RFC8345)
      # @return [Array<MddoL3FirewallPolicy>]
      def convert_policies(data)
        key = @attr_table.ext_of(:policies)
        operative_array_key?(data, key) ? data[key].map { |p| MddoL3FirewallPolicy.new(p, key) } : []
      end
    end
  end
end
