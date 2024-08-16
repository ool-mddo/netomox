# frozen_string_literal: true

require 'netomox/topology/attr_base'
require 'netomox/topology/node_attr/mddo_bgp_policy_as_path_set'
require 'netomox/topology/node_attr/mddo_bgp_policy_action'
require 'netomox/topology/node_attr/mddo_bgp_policy_condition'

module Netomox
  module Topology
    # prefix-set for bgp-policy
    class MddoBgpPrefixSet < SubAttributeBase
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] prefixes
      #   @return [Array<MddoBgpPrefix>]
      attr_accessor :name, :prefixes

      # Attribute defs
      ATTR_DEFS = [
        { int: :name, ext: 'name', default: '' },
        { int: :prefixes, ext: 'prefixes', default: [] }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        @prefixes = convert_prefixes(data)
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [Array<MddoBgpPrefix>] Converted attribute data
      def convert_prefixes(data)
        key = @attr_table.ext_of(:prefixes)
        operative_array_key?(data, key) ? data[key].map { |d| MddoBgpPrefix.new(d, key) } : []
      end
    end

    # sub-data of prefix-set
    class MddoBgpPrefix < SubAttributeBase
      # @!attribute [rw] prefix
      #   @return [String]
      attr_accessor :prefix

      # Attribute defs
      ATTR_DEFS = [{ int: :prefix, ext: 'prefix', default: '' }].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end
    end

    # bgp-community-set for bgp-policy
    class MddoBgpCommunitySet < SubAttributeBase
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] communities
      #   @return [Array<String>]
      attr_accessor :name, :communities

      # Attribute defs
      ATTR_DEFS = [
        { int: :name, ext: 'name', default: '' },
        { int: :communities, ext: 'communities', default: [] }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        @communities = convert_communities(data)
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [Array<MddoBgpCommunity>] Converted attribute data
      def convert_communities(data)
        key = @attr_table.ext_of(:communities)
        operative_array_key?(data, key) ? data[key].map { |d| MddoBgpCommunity.new(d, key) } : []
      end
    end

    # sub-data of bgp-community-set
    class MddoBgpCommunity < SubAttributeBase
      # @!attribute [rw] community
      #   @return [String]
      attr_accessor :community

      # Attribute defs
      ATTR_DEFS = [{ int: :community, ext: 'community', default: '' }].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end
    end

    # bgp-policy
    class MddoBgpPolicy < SubAttributeBase
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] default
      #   @return [MddoBgpPolicyDefaultStatement]
      # @!attribute [rw] statements
      #   @return [Array<MddoBgpPolicyStatement>]
      attr_accessor :name, :default, :statements

      # Attribute defs
      ATTR_DEFS = [
        { int: :name, ext: 'name', default: '' },
        { int: :default, ext: 'default', default: {} },
        { int: :statements, ext: 'statements', default: [] }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        @default = convert_default(data)
        @statements = convert_statements(data)
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [MddoBgpPolicyDefaultStatement] Converted attribute data
      def convert_default(data)
        key = @attr_table.ext_of(:default)
        MddoBgpPolicyDefaultStatement.new(data[key], key)
      end

      # @param [Hash] data Attribute data (RFC8345)
      # @return [Array<MddoBgpPolicyStatement>] Converted attribute data
      def convert_statements(data)
        key = @attr_table.ext_of(:statements)
        operative_array_key?(data, key) ? data[key].map { |d| MddoBgpPolicyStatement.new(d, key) } : []
      end
    end

    # Base class of bgp policy statement
    class MddoBgpPolicyStatementBase < SubAttributeBase
      # action keyword and corresponding attribute class
      ACTION_ATTR = {
        'apply' => MddoBgpPolicyActionApply,
        'target' => MddoBgpPolicyActionTarget,
        'community' => MddoBgpPolicyActionCommunity,
        'next-hop' => MddoBgpPolicyActionNextHop,
        'local-preference' => MddoBgpPolicyActionLocalPreference,
        'metric' => MddoBgpPolicyActionMetric,
        'as-path-prepend' => MddoBgpPolicyActionAsPathPrepend
      }.freeze

      # condition keyword and corresponding attribute class
      CONDITION_ATTR = {
        'protocol' => MddoBgpPolicyConditionProtocol,
        'rib' => MddoBgpPolicyConditionRib,
        'route-filter' => MddoBgpPolicyConditionRouteFilter,
        'policy' => MddoBgpPolicyConditionPolicy,
        'as-path-group' => MddoBgpPolicyConditionAsPathGroup,
        'community' => MddoBgpPolicyConditionCommunity,
        'prefix-list' => MddoBgpPolicyConditionPrefixList,
        'prefix-list-filter' => MddoBgpPolicyConditionPrefixListFilter
      }.freeze

      protected

      # @param [String] action_key
      # @return [MddoBgpPolicyAction, nil] Action attribute class correspond with the action key
      def action_attr(action_key)
        return ACTION_ATTR[action_key] if ACTION_ATTR.key?(action_key)

        Netomox.logger.error "Unknown bgp-policy action keyword: #{action_key}"
        nil # error
      end

      # @param [String] condition_key
      # @return [MddoBgpPolicyCondition, nil] Condition attribute class correspond with the action key
      def condition_attr(condition_key)
        return CONDITION_ATTR[condition_key] if CONDITION_ATTR.key?(condition_key)

        Netomox.logger.error "Unknown bgp-policy condition keyword: #{condition_key}"
        nil # error
      end
    end

    # sub-data of bgp-policy
    class MddoBgpPolicyDefaultStatement < MddoBgpPolicyStatementBase
      # @!attribute [rw] actions
      #   @return [Array<MddoBgpPolicyAction>]
      attr_accessor :actions

      # Attribute defs
      ATTR_DEFS = [{ int: :actions, ext: 'actions', default: [] }].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        @actions = convert_statements(data)
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [Array<MddoBgpPolicyAction>] Converted attribute data
      def convert_statements(data)
        key = @attr_table.ext_of(:actions)
        return [] unless operative_array_key?(data, key)

        # NOTE: if policy action includes unknown keyword, action_attr returns nil -> ignore it
        data[key].map { |d| action_attr(d.keys[0])&.new(d, key) }.compact
      end
    end

    # sub-data of bgp-policy
    class MddoBgpPolicyStatement < MddoBgpPolicyStatementBase
      # default value of 'if' attr
      DEFAULT_IF_VALUE = '__UNKNOWN__'

      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] actions
      #   @return [Array<MddoBgpPolicyAction>]
      # @!attribute [rw] conditions
      #   @return [Array<MddoBgpPolicyCondition>]
      # @!attribute [rw] if (NOTICE: optional)
      #   @return [String]
      attr_accessor :name, :actions, :conditions, :if

      # Attribute defs
      ATTR_DEFS = [
        { int: :name, ext: 'name', default: '' },
        { int: :actions, ext: 'actions', default: [] },
        { int: :conditions, ext: 'conditions', default: [] },
        { int: :if, ext: 'if', default: DEFAULT_IF_VALUE }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        @actions = convert_actions(data)
        @conditions = convert_conditions(data)
      end

      # Convert to data for RFC8345 format
      # @return [Hash]
      def to_data
        data = super
        data.delete('if') if @if == DEFAULT_IF_VALUE
        data
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [Array<MddoBgpPolicyAction>] Converted attribute data
      def convert_actions(data)
        key = @attr_table.ext_of(:actions)
        return [] unless operative_array_key?(data, key)

        # NOTE: if policy action includes unknown keyword, action_attr returns nil -> ignore it
        data[key].map { |d| action_attr(d.keys[0])&.new(d, key) }.compact
      end

      # @param [Hash] data Attribute data (RFC8345)
      # @return [Array<MddoBgpPolicyCondition>] Converted attribute data
      def convert_conditions(data)
        key = @attr_table.ext_of(:conditions)
        operative_array_key?(data, key) ? data[key].map { |d| condition_attr(d.keys[0])&.new(d, key) }.compact : []
      end
    end
  end
end
