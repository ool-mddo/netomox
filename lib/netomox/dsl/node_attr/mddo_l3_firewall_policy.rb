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
      #   @return [String]
      # @!attribute [rw] source_address
      #   @return [String]
      # @!attribute [rw] destination_address
      #   @return [String]
      attr_accessor :name, :action, :application, :source_address, :destination_address

      # @param [String] name Rule name
      # @param [String] action 'permit' or 'deny'
      # @param [String] application Application filter
      # @param [String] source_address Source address or 'any'
      # @param [String] destination_address Destination address or 'any'
      def initialize(name: '', action: '', application: '', source_address: '', destination_address: '')
        @name = name
        @action = action
        @application = application
        @source_address = source_address
        @destination_address = destination_address
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'name' => @name,
          'action' => @action,
          'application' => @application,
          'source-address' => @source_address,
          'destination-address' => @destination_address
        }
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
          'from-zone' => @from_zone,
          'to-zone' => @to_zone,
          'rule' => @rules.map(&:topo_data)
        }
      end
    end
  end
end
