# frozen_string_literal: true

require 'netomox/topology/attr_base'

module Netomox
  module Topology
    # Firewall cluster pair for L3 node attribute
    class MddoL3FirewallPair < SubAttributeBase
      # @!attribute [rw] primary
      #   @return [String]
      # @!attribute [rw] secondary
      #   @return [String]
      attr_accessor :primary, :secondary

      ATTR_DEFS = [
        { int: :primary, ext: 'primary', default: '' },
        { int: :secondary, ext: 'secondary', default: '' }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end
    end
  end
end
