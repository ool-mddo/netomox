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
      #   @return [Array<String>] (a String input is converted to a single-element Array)
      # @!attribute [rw] source_address
      #   @return [Array<String>] (a String input is converted to a single-element Array)
      # @!attribute [rw] destination_address
      #   @return [Array<String>] (a String input is converted to a single-element Array)
      attr_accessor :name, :action, :application, :source_address, :destination_address

      # Convert a value to an array of strings (legacy String data is accepted, an empty string is converted to [])
      # NOTE: always return a new Array, not to share the default value and the input data between instances
      TO_STRING_ARRAY = lambda do |value|
        value.is_a?(String) && value.empty? ? [] : Array(value).dup
      end

      ATTR_DEFS = [
        { int: :name, ext: 'name', default: '' },
        { int: :action, ext: 'action', default: '' },
        { int: :application, ext: 'application', default: [], convert: TO_STRING_ARRAY },
        { int: :source_address, ext: 'source_address', default: [], convert: TO_STRING_ARRAY },
        { int: :destination_address, ext: 'destination_address', default: [], convert: TO_STRING_ARRAY }
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
        { int: :from_zone, ext: 'from_zone', default: '' },
        { int: :to_zone, ext: 'to_zone', default: '' },
        { int: :rules, ext: 'rules', default: [] }
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
