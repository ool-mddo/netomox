# frozen_string_literal: true

require 'netomox/const'
require 'netomox/dsl/node_attr/mddo_l3_firewall_pair'
require 'netomox/dsl/node_attr/mddo_l3_firewall_zone'
require 'netomox/dsl/node_attr/mddo_l3_firewall_policy'

module Netomox
  module DSL
    # Firewall attribute container for MDDO L3 node attribute
    class MddoL3Firewall
      # @!attribute [rw] pair
      #   @return [MddoL3FirewallPair]
      # @!attribute [rw] zones
      #   @return [Array<MddoL3FirewallZone>]
      # @!attribute [rw] policies
      #   @return [Array<MddoL3FirewallPolicy>]
      attr_accessor :pair, :zones, :policies

      # @param [Hash] pair Cluster pair data
      # @param [Array<Hash>] zones Security zone definitions
      # @param [Array<Hash>] policies Security policies between zones
      def initialize(pair: {}, zones: [], policies: [])
        @pair = MddoL3FirewallPair.new(**pair)
        @zones = zones.map { |z| MddoL3FirewallZone.new(**z) }
        @policies = policies.map { |p| MddoL3FirewallPolicy.new(**p) }
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'pair' => @pair.topo_data,
          'zone' => @zones.map(&:topo_data),
          'policy' => @policies.map(&:topo_data)
        }
      end

      # @return [Boolean]
      def empty?
        @pair.primary.empty? && @pair.secondary.empty? && @zones.empty? && @policies.empty?
      end
    end
  end
end
