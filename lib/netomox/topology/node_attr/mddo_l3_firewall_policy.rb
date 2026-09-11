# frozen_string_literal: true

require 'netomox/topology/attr_base'

module Netomox
  module Topology
    # Firewall policy rule for L3 node attribute
    class MddoL3FirewallPolicyRule < SubAttributeBase
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] action
      #   @return [String] 'permit' or 'deny'
      # @!attribute [rw] application
      #   @return [String]
      # @!attribute [rw] source_address
      #   @return [String]
      # @!attribute [rw] destination_address
      #   @return [String]
      attr_accessor :name, :action, :application, :source_address, :destination_address

      ATTR_DEFS = [
        { int: :name, ext: 'name', default: '' },
        { int: :action, ext: 'action', default: '' },
        { int: :application, ext: 'application', default: '' },
        { int: :source_address, ext: 'source-address', default: '' },
        { int: :destination_address, ext: 'destination-address', default: '' }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end
    end

    # Firewall security policy between zones for L3 node attribute
    class MddoL3FirewallPolicy < SubAttributeBase
      # @!attribute [rw] from_zone
      #   @return [String]
      # @!attribute [rw] to_zone
      #   @return [String]
      # @!attribute [rw] rules
      #   @return [Array<MddoL3FirewallPolicyRule>]
      attr_accessor :from_zone, :to_zone, :rules

      ATTR_DEFS = [
        { int: :from_zone, ext: 'from-zone', default: '' },
        { int: :to_zone, ext: 'to-zone', default: '' },
        { int: :rules, ext: 'rule', default: [] }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        @rules = convert_rules(data)
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [Array<MddoL3FirewallPolicyRule>]
      def convert_rules(data)
        key = @attr_table.ext_of(:rules)
        operative_array_key?(data, key) ? data[key].map { |r| MddoL3FirewallPolicyRule.new(r, key) } : []
      end
    end
  end
end
