# frozen_string_literal: true

require 'netomox/dsl/error'

module Netomox
  module DSL
    # Base class of bgp-policy action/condition
    class MddoBgpPolicyElementBase
      # @!attribute [rw] key
      #   @return [Symbol]
      # @!attribute [rw] value
      #   @return [Integer, String. MddoBgpPolicyActionCommunity]
      attr_accessor :key, :value

      # @param [Hash] data Data of bgp-policy action/condition
      # @param [Array<Symbol>] keyword_list
      def initialize(data, keyword_list)
        @key = data.keys[0]
        unless keyword_list.include?(@key)
          raise DSLInvalidArgumentError, "Unknown bgp-policy element keyword: #{@key} in #{data}"
        end

        @value = instantiate_value(data[@key])
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          @key.to_s.gsub('_', '-') => convert_value_to_topo_data(@value)
        }
      end

      protected

      # @param [Object] value Value of bgp-policy action/condition
      # @return [Object] Instance of the value
      def instantiate_value(value)
        value
      end

      private

      # @param [Object] value_obj Value-object (instantiated value) of bgp-policy action/condition
      # @return [Array<Hash>|Hash] RF8345-topology data (converted value)
      def convert_value_to_topo_data(value_obj)
        return value_obj.map { |v| convert_value_to_topo_data(v) } if value_obj.is_a?(Array)

        if value_obj.respond_to?(:topo_data)
          value_obj.topo_data
        else
          value_obj
        end
      end
    end
  end
end
