# frozen_string_literal: true

require 'netomox/const'

module Netomox
  module DSL
    # Firewall security zone for MDDO L3 node attribute
    class MddoL3FirewallZone
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] interfaces
      #   @return [Array<String>]
      attr_accessor :name, :interfaces

      # @param [String] name Zone name
      # @param [Array<String>] interfaces Interface names belonging to this zone
      def initialize(name: '', interfaces: [])
        @name = name
        @interfaces = interfaces
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'name' => @name,
          'interface' => @interfaces
        }
      end
    end
  end
end
