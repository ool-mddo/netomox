# frozen_string_literal: true

require 'netomox/const'
require 'netomox/dsl/node_attr/mddo_l3_firewall_cluster_pair'
require 'netomox/dsl/node_attr/mddo_l3_firewall_zone'
require 'netomox/dsl/node_attr/mddo_l3_firewall_policy'

module Netomox
  module DSL
    # Firewall attribute container for MDDO L3 node attribute
    class MddoL3Firewall
      # @!attribute [rw] cluster_firewall_pairs
      #   @return [Array<MddoL3FirewallClusterPair>]
      # @!attribute [rw] zones
      #   @return [Array<MddoL3FirewallZone>]
      # @!attribute [rw] policies
      #   @return [Array<MddoL3FirewallPolicy>]
      attr_accessor :cluster_firewall_pairs, :zones, :policies

      # @param [Array<Hash>] cluster_firewall_pairs Cluster pair definitions
      # @param [Array<Hash>] zones Security zone definitions
      # @param [Array<Hash>] policies Security policies between zones
      def initialize(cluster_firewall_pairs: [], zones: [], policies: [])
        @cluster_firewall_pairs = cluster_firewall_pairs.map { |p| MddoL3FirewallClusterPair.new(**p) }
        @zones = zones.map { |z| MddoL3FirewallZone.new(**z) }
        @policies = policies.map { |p| MddoL3FirewallPolicy.new(**p) }
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'cluster-firewall-pair' => @cluster_firewall_pairs.map(&:topo_data),
          'zone' => @zones.map(&:topo_data),
          'policy' => @policies.map(&:topo_data)
        }
      end

      # @return [Boolean]
      def empty?
        @cluster_firewall_pairs.empty?
      end
    end
  end
end
