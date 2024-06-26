# frozen_string_literal: true

require 'netomox/topology/attr_base'
require 'netomox/topology/diffable_forward'
require 'netomox/topology/node_attr/rfc_prefix'

module Netomox
  module Topology
    # L3 node attribute base which has prefixes
    class L3NodeAttributeBase < AttributeBase
      # @!attribute [rw] prefixes
      #   @return [Array<L3Prefix>]
      # @!attribute [rw] flags
      #   @return [Array<String>]
      attr_accessor :prefixes, :flags

      # Attribute definition of L3 node
      ATTR_DEFS = [
        { int: :prefixes, ext: 'prefix', default: [] },
        { int: :flags, ext: 'flag', default: [] }
      ].freeze

      include Diffable

      # @param [Array<Hash>] attr_table Attribute data
      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(attr_table, data, type)
        super(ATTR_DEFS + attr_table, data, type) # merge ATTR_DEFS
        @prefixes = convert_prefixes(data)
      end

      # @return [String]
      def to_s
        "attribute: #{@name}"
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [Array<L3Prefix>] Converted attribute data
      def convert_prefixes(data)
        key = @attr_table.ext_of(:prefixes)
        operative_array_key?(data, key) ? data[key].map { |p| L3Prefix.new(p, key) } : []
      end
    end
  end
end
