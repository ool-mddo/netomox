# frozen_string_literal: true

require 'netomox/topology/attr_base'

module Netomox
  module Topology
    # Redistribute config for MDDO ospf-area node attribute
    class MddoOspfRedistribute < SubAttributeBase
      # @!attribute [rw] protocol
      #   @return [String]
      #   @todo enum (static, connected)
      # @!attribute [rw] metric_type
      #   @return [Integer]
      #   @todo enum (1, 2) : (OE1, OE2)
      attr_accessor :protocol, :metric_type

      # Attribute definition of L3 prefix (for L3 node)
      ATTR_DEFS = [
        { int: :protocol, ext: 'protocol', default: '' },
        { int: :metric_type, ext: 'metric-type', default: 2 }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end
    end
  end
end
