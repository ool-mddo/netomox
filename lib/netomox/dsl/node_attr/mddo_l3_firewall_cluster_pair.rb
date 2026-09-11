# frozen_string_literal: true

require 'netomox/const'
require 'netomox/dsl/node_attr/mddo_l3_firewall_atypical_interface'

module Netomox
  module DSL
    # A node (primary or secondary) in a firewall cluster pair
    class MddoL3FirewallClusterNode
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] atypical_interfaces
      #   @return [Array<MddoL3FirewallAtypicalInterface>]
      attr_accessor :name, :atypical_interfaces

      # @param [String] name Node name
      # @param [Array<Hash>] atypical_interfaces Atypical interface definitions
      def initialize(name: '', atypical_interfaces: [])
        @name = name
        @atypical_interfaces = atypical_interfaces.map { |i| MddoL3FirewallAtypicalInterface.new(**i) }
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'name' => @name,
          'atypical-interface' => @atypical_interfaces.map(&:topo_data)
        }
      end
    end

    # A primary/secondary firewall cluster pair
    class MddoL3FirewallClusterPair
      # @!attribute [rw] primary
      #   @return [MddoL3FirewallClusterNode]
      # @!attribute [rw] secondary
      #   @return [MddoL3FirewallClusterNode]
      attr_accessor :primary, :secondary

      # @param [Hash] primary Primary node data
      # @param [Hash] secondary Secondary node data
      def initialize(primary: {}, secondary: {})
        @primary = MddoL3FirewallClusterNode.new(**primary)
        @secondary = MddoL3FirewallClusterNode.new(**secondary)
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'primary' => @primary.topo_data,
          'secondary' => @secondary.topo_data
        }
      end
    end
  end
end
