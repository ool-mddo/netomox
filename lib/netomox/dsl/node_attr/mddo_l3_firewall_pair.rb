# frozen_string_literal: true

require 'netomox/const'

module Netomox
  module DSL
    # Firewall cluster pair for MDDO L3 node attribute
    class MddoL3FirewallPair
      # @!attribute [rw] primary
      #   @return [String]
      # @!attribute [rw] secondary
      #   @return [String]
      attr_accessor :primary, :secondary

      # @param [String] primary Primary node name
      # @param [String] secondary Secondary node name
      def initialize(primary: '', secondary: '')
        @primary = primary
        @secondary = secondary
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'primary' => @primary,
          'secondary' => @secondary
        }
      end
    end
  end
end
