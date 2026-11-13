# frozen_string_literal: true

require 'netomox/const'

module Netomox
  module DSL
    # Firewall policy rule for MDDO L3 node attribute
    class MddoL3FirewallPolicyRule
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] action
      #   @return [String] 'permit' or 'deny'
      # @!attribute [rw] application
      #   @return [Array<String>]
      # @!attribute [rw] source_address
      #   @return [Array<String>]
      # @!attribute [rw] destination_address
      #   @return [Array<String>]
      attr_accessor :name, :action, :application, :source_address, :destination_address

      # @param [String] name Rule name
      # @param [String] action 'permit' or 'deny'
      # @param [Array<String>, String] application Application filter(s)
      # @param [Array<String>, String] source_address Source address(es) or 'any'
      # @param [Array<String>, String] destination_address Destination address(es) or 'any'
      def initialize(name: '', action: '', application: [], source_address: [], destination_address: [])
        @name = name
        @action = action
        @application = to_string_array(application)
        @source_address = to_string_array(source_address)
        @destination_address = to_string_array(destination_address)
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'name' => @name,
          'action' => @action,
          'application' => @application,
          'source_address' => @source_address,
          'destination_address' => @destination_address
        }
      end

      private

      # @param [Array<String>, String] value
      # @return [Array<String>] (a String is converted to a single-element Array, an empty string to [])
      #   always a new Array (not shared with the input)
      def to_string_array(value)
        value.is_a?(String) && value.empty? ? [] : Array(value).dup
      end
    end

    # Firewall security policy between zones for MDDO L3 node attribute
    class MddoL3FirewallPolicy
      # @!attribute [rw] from_zone
      #   @return [String]
      # @!attribute [rw] to_zone
      #   @return [String]
      # @!attribute [rw] rules
      #   @return [Array<MddoL3FirewallPolicyRule>]
      attr_accessor :from_zone, :to_zone, :rules

      # @param [String] from_zone Source zone name
      # @param [String] to_zone Destination zone name
      # @param [Array<Hash>] rules Policy rules
      def initialize(from_zone: '', to_zone: '', rules: [])
        @from_zone = from_zone
        @to_zone = to_zone
        @rules = rules.map { |r| MddoL3FirewallPolicyRule.new(**r) }
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'from_zone' => @from_zone,
          'to_zone' => @to_zone,
          'rules' => @rules.map(&:topo_data)
        }
      end
    end
  end
end
