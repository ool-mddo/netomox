# frozen_string_literal: true

require 'netomox/const'

module Netomox
  module DSL
    # FHRP (First Hop Redundancy Protocol: VRRP/HSRP) group config for mddo-topology L3 term-point
    class MddoFhrp
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
      #   @return [String]
      # @!attribute [rw] active
      #   @return [Boolean]
      attr_accessor :protocol, :group_id, :virtual_addresses, :priority, :preempt, :source_address, :active

      # rubocop:disable Metrics/ParameterLists

      # @param [String] protocol 'vrrp' or 'hsrp'
      # @param [Integer] group_id Group ID
      # @param [Array<String>] virtual_addresses Virtual IP addresses
      # @param [Integer] priority Priority
      # @param [Boolean] preempt Preempt
      # @param [String] source_address IP address/prefix-length of the interface owns the group
      # @param [Boolean] active Active
      def initialize(protocol: '', group_id: -1, virtual_addresses: [], priority: 0, preempt: false,
                     source_address: '', active: false)
        @protocol = protocol
        @group_id = group_id
        @virtual_addresses = virtual_addresses
        @priority = priority
        @preempt = preempt
        @source_address = source_address
        @active = active
      end
      # rubocop:enable Metrics/ParameterLists

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'protocol' => @protocol,
          'group-id' => @group_id,
          'virtual-address' => @virtual_addresses,
          'priority' => @priority,
          'preempt' => @preempt,
          'source-address' => @source_address,
          'active' => @active
        }
      end
    end
  end
end
