# frozen_string_literal: true

require 'netomox/dsl/node_attr/mddo_bgp_policy_element_base'

module Netomox
  module DSL
    # sub-data of bgp-policy and bgp-policy-statement
    class MddoBgpPolicyAction < MddoBgpPolicyElementBase
      # action keywords
      #   NOTE: unknown_bgp_action_key -> to test Netomox::Topology::MddoBgpPolicyAction
      KEYWORDS = %i[apply target community next_hop local_preference metric as_path_prepend
                    unknown_bgp_action_key].freeze

      # @param [Hash] action_data
      #   NOTE: action is single key-value hash; like `action = { key => [Integer, String, Hash] }`
      def initialize(action_data)
        super(action_data, KEYWORDS)
      end

      protected

      # @param [Array<Hash>, Hash] value Value of bgp-policy action/condition
      # @return [Array<Object>, Object] Value of @key
      def instantiate_value(value)
        case @key
        when :community
          MddoBgpPolicyActionCommunity.new(**value)
        when :as_path_prepend
          value.map { |v| MddoBgpPolicyActionAsPathPrepend.new(**v) }
        else
          value
        end
      end
    end

    # sub-data of bgp-policy-action
    class MddoBgpPolicyActionAsPathPrepend
      # @!attribute [rw] asn
      #   @return [Integer]
      # @!attribute [rw] repeat
      #   @return [Integer]
      attr_accessor :asn, :repeat

      # @param [String, Integer] asn AS number
      # repeat [String, Integer] repeat Repeat number (default: 1)
      def initialize(asn: -1, repeat: 1)
        # asn is "(asn)x(repeat)" or "(asn)*(repeat)" string
        if asn.is_a?(String) && asn =~ /(\d+)[x*](\d+)/
          asn = Regexp.last_match(1).to_i
          repeat = Regexp.last_match(2).to_i
        end
        @asn = asn.is_a?(Integer) ? asn : asn.to_i
        @repeat = repeat.is_a?(Integer) ? repeat : repeat.to_i
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'asn' => @asn,
          'repeat' => @repeat
        }
      end
    end

    # sub-data of bgp-policy-action
    class MddoBgpPolicyActionCommunity
      # @!attribute [rw] action
      #   @return [String]
      # @!attribute [rw] name
      #   @return [String]
      attr_accessor :action, :name

      # @param [String] action
      # @param [String] name
      def initialize(action: '', name: '')
        @action = action
        @name = name
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'action' => @action,
          'name' => @name
        }
      end
    end
  end
end
