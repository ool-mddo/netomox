# frozen_string_literal: true

require 'netomox/topology/attr_base'

module Netomox
  module Topology
    # FHRP (First Hop Redundancy Protocol: VRRP/HSRP) group config for L3 term-point
    class MddoFhrp < SubAttributeBase
      # @!attribute [rw] protocol
      #   @return [String] 'vrrp' or 'hsrp'
      # @!attribute [rw] group_id
      #   @return [Integer]
      # @!attribute [rw] virtual_addresses
      #   @return [Array<String>]
      # @!attribute [rw] priority
      #   @return [Integer]
      # @!attribute [rw] preempt
      #   @return [Boolean]
      # @!attribute [rw] source_address
      #   @return [String] IP address/prefix-length of the interface owns the group
      # @!attribute [rw] active
      #   @return [Boolean]
      attr_accessor :protocol, :group_id, :virtual_addresses, :priority, :preempt, :source_address, :active

      # Attribute definition of MDDO FHRP
      ATTR_DEFS = [
        { int: :protocol, ext: 'protocol', default: '' },
        { int: :group_id, ext: 'group-id', default: -1, convert: lambda(&:to_i) },
        { int: :virtual_addresses, ext: 'virtual-address', default: [] },
        { int: :priority, ext: 'priority', default: 0, convert: lambda(&:to_i) },
        { int: :preempt, ext: 'preempt', default: false },
        { int: :source_address, ext: 'source-address', default: '' },
        { int: :active, ext: 'active', default: false }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "fhrp: protocol:#{protocol}, group_id:#{group_id}, virtual_addresses:#{virtual_addresses}"
      end
    end
  end
end
