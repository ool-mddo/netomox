# frozen_string_literal: true

require 'netomox/topology/attr_base'

module Netomox
  module Topology
    # Fabric-specific options for a firewall atypical interface
    class MddoL3FirewallFabricOptions < SubAttributeBase
      # @!attribute [rw] member_interfaces
      #   @return [Array<String>]
      attr_accessor :member_interfaces

      ATTR_DEFS = [
        { int: :member_interfaces, ext: 'member-interface', default: [] }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end
    end

    # Atypical interface (fabric/control) on a firewall cluster node
    class MddoL3FirewallAtypicalInterface < SubAttributeBase
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] role
      #   @return [String] 'fabric' or 'control'
      # @!attribute [rw] fabric_options
      #   @return [MddoL3FirewallFabricOptions]
      attr_accessor :name, :role, :fabric_options

      ATTR_DEFS = [
        { int: :name, ext: 'name', default: '' },
        { int: :role, ext: 'role', default: '' },
        { int: :fabric_options, ext: 'fabric-options', default: {} }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        @fabric_options = convert_fabric_options(data)
      end

      def to_data
        data = super
        data.delete('fabric-options') unless @role == 'fabric'
        data
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [MddoL3FirewallFabricOptions]
      def convert_fabric_options(data)
        key = @attr_table.ext_of(:fabric_options)
        MddoL3FirewallFabricOptions.new(operative_hash_key?(data, key) ? data[key] : {}, key)
      end
    end
  end
end
