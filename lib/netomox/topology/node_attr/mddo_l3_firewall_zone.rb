# frozen_string_literal: true

require 'netomox/topology/attr_base'

module Netomox
  module Topology
    # Firewall security zone for L3 node attribute
    class MddoL3FirewallZone < SubAttributeBase
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] interfaces
      #   @return [Array<String>]
      attr_accessor :name, :interfaces

      ATTR_DEFS = [
        { int: :name, ext: 'name', default: '' },
        { int: :interfaces, ext: 'interface', default: [] }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end
    end
  end
end
