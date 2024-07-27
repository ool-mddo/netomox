# frozen_string_literal: true

require 'netomox/dsl/node_attr/mddo_bgp_policy_element_base'

module Netomox
  module DSL
    # sub-data of bgp-policy-statement
    class MddoBgpPolicyCondition < MddoBgpPolicyElementBase
      # action keywords
      KEYWORDS = %i[protocol rib route_filter policy as_path_group community prefix_list prefix_list_filter].freeze

      # @param [Hash] condition_data
      #   NOTE: condition is single key-value hash; like `condition = { key => [String, Hash, Array<String>] }`
      def initialize(condition_data)
        super(condition_data, KEYWORDS)
      end

      private

      # @param [Hash] value Value of bgp-policy action/condition
      # @return [Object] Value of @key
      def instantiate_value(value)
        case @key
        when :route_filter
          MddoBgpPolicyConditionRouteFilter.new(**value)
        when :prefix_list_filter
          MddoBgpPolicyConditionPrefixListFilter.new(**value)
        else
          value
        end
      end
    end

    # sub-data of bgp-policy-condition
    class MddoBgpPolicyConditionRouteFilter
      # @!attribute [rw] length
      #   @return [BgpPolicyConditionRFLength]
      # @!attribute [rw] match_type
      #   @return [String]
      # @!attribute [rw] prefix
      #   @return [String]
      attr_accessor :length, :match_type, :prefix

      # @param [Hash] length
      # @param [String] match_type
      # @param [String] prefix
      def initialize(length: {}, match_type: '', prefix: '')
        @length = BgpPolicyConditionRFLength.new(**length)
        @match_type = match_type
        @prefix = prefix
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'length' => @length.topo_data,
          'match-type' => @match_type,
          'prefix' => @prefix
        }
      end
    end

    # sub-data of bgp-policy-condition
    class MddoBgpPolicyConditionPrefixListFilter
      # @!attribute [rw] match_type
      #   @return [String]
      # @!attribute [rw] prefix_list A name of prefix-set
      #   @return [String]
      attr_accessor :match_type, :prefix_list

      # @param [String] match_type
      # @param [String] prefix_list
      def initialize(match_type: '', prefix_list: '')
        @match_type = match_type
        @prefix_list = prefix_list
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'match-type' => @match_type,
          'prefix-list' => @prefix_list
        }
      end
    end

    # sub-data of bgp-policy-condition-route-filter (Route-Filter-Length)
    class BgpPolicyConditionRFLength
      # @!attribute [rw] max
      #   @return [Integer]
      # @!attribute [rw] min
      #   @return [Integer]
      attr_accessor :max, :min

      # @param [Integer, String] max
      # @param [Integer, String] min
      def initialize(min: -1, max: -1)
        @min = min.to_i
        @max = max.to_i
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        return {} if @max.negative? && @min.negative?

        {
          'min' => @min,
          'max' => @max
        }
      end
    end
  end
end
