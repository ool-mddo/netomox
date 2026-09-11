# frozen_string_literal: true

require 'netomox/topology/attr_base'
require 'netomox/topology/node_attr/mddo_l3_firewall_atypical_interface'

module Netomox
  module Topology
    # A node (primary or secondary) in a firewall cluster pair
    class MddoL3FirewallClusterNode < SubAttributeBase
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] atypical_interfaces
      #   @return [Array<MddoL3FirewallAtypicalInterface>]
      attr_accessor :name, :atypical_interfaces

      ATTR_DEFS = [
        { int: :name, ext: 'name', default: '' },
        { int: :atypical_interfaces, ext: 'atypical-interface', default: [] }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        @atypical_interfaces = convert_atypical_interfaces(data)
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [Array<MddoL3FirewallAtypicalInterface>]
      def convert_atypical_interfaces(data)
        key = @attr_table.ext_of(:atypical_interfaces)
        operative_array_key?(data, key) ? data[key].map { |i| MddoL3FirewallAtypicalInterface.new(i, key) } : []
      end
    end

    # A primary/secondary firewall cluster pair
    class MddoL3FirewallClusterPair < SubAttributeBase
      # @!attribute [rw] primary
      #   @return [MddoL3FirewallClusterNode]
      # @!attribute [rw] secondary
      #   @return [MddoL3FirewallClusterNode]
      attr_accessor :primary, :secondary

      ATTR_DEFS = [
        { int: :primary, ext: 'primary', default: {} },
        { int: :secondary, ext: 'secondary', default: {} }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        @primary = convert_node(data, :primary)
        @secondary = convert_node(data, :secondary)
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @param [Symbol] key_sym Internal key (:primary or :secondary)
      # @return [MddoL3FirewallClusterNode]
      def convert_node(data, key_sym)
        key = @attr_table.ext_of(key_sym)
        MddoL3FirewallClusterNode.new(operative_hash_key?(data, key) ? data[key] : {}, key)
      end
    end
  end
end
