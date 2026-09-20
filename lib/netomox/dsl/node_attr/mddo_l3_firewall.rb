# frozen_string_literal: true

require 'netomox/const'
require 'netomox/dsl/node_attr/mddo_l3_firewall_cluster_pair'
require 'netomox/dsl/node_attr/mddo_l3_firewall_zone'
require 'netomox/dsl/node_attr/mddo_l3_firewall_policy'

module Netomox
  module DSL
    # Firewall attribute container for MDDO L3 node attribute
    class MddoL3Firewall
      # @!attribute [rw] node
      #   @return [String]
      # @!attribute [rw] pair
      #   @return [Hash] HA cluster pair (primary/secondary), stored as raw hash
      # @!attribute [rw] zones
      #   @return [Array<MddoL3FirewallZone>]
      # @!attribute [rw] policies
      #   @return [Array<MddoL3FirewallPolicy>]
      attr_accessor :node, :pair, :zones, :policies

      # @param [String] node Node name
      # @param [Hash] pair HA cluster pair data (primary/secondary)
      # @param [Array<Hash>] zones Security zone definitions
      # @param [Array<Hash>] policies Security policies between zones
      def initialize(node: '', pair: {}, zones: [], policies: [])
        @node = node
        @pair = pair
        @zones = zones.map { |z| MddoL3FirewallZone.new(**z) }
        @policies = policies.map { |p| MddoL3FirewallPolicy.new(**p) }
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        data = {}
        data['node'] = @node unless @node.empty?
        data['pair'] = stringify_keys(@pair) unless @pair.empty?
        data['zones'] = @zones.map(&:topo_data) unless @zones.empty?
        data['policies'] = @policies.map(&:topo_data) unless @policies.empty?
        data
      end

      # @return [Boolean]
      def empty?
        @node.empty? && @pair.empty? && @zones.empty? && @policies.empty?
      end

      private

      # Recursively convert all Hash keys to strings for stable topo_data output
      def stringify_keys(obj)
        case obj
        when Hash then obj.to_h { |k, v| [k.to_s, stringify_keys(v)] }
        when Array then obj.map { |v| stringify_keys(v) }
        else obj
        end
      end
    end
  end
end
