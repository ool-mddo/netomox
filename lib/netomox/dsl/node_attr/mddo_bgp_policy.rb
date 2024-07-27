# frozen_string_literal: true

require 'netomox/dsl/node_attr/mddo_bgp_policy_action'
require 'netomox/dsl/node_attr/mddo_bgp_policy_condition'

module Netomox
  module DSL
    # attribute for mddo-topology bgp-proc node bgp-policy: prefix-set
    class MddoBgpPrefixSet
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] prefixes
      #   @return [Array<String>]
      attr_accessor :name, :prefixes

      # @param [String] name
      # @param [Array<String>] prefixes
      def initialize(name: '', prefixes: [])
        @name = name
        @prefixes = prefixes.map { |p| MddoBgpPrefix.new(**p) }
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'name' => @name,
          'prefixes' => @prefixes.map(&:topo_data)
        }
      end
    end

    # sub-data of prefix-set
    class MddoBgpPrefix
      # @!attribute [rw] prefix
      #   @return [String]
      attr_accessor :prefix

      # @param [Hash] prefix_data
      # NOTE: prefix is single key-value hash
      #   like: `prefix = { 'prefix' => 'x.x.x.x/nn' }`
      def initialize(prefix_data)
        @prefix = prefix_data[:prefix]
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        { 'prefix' => @prefix }
      end
    end

    # attribute for mddo-topology bgp-proc node bgp-policy: bgp-as-path-set
    class MddoBgpAsPathSet
      # @!attribute [rw] as_path
      #   @return [MddoBgpAsPath]
      # @!attribute [rw] group_name
      #   @return [String]
      attr_accessor :as_path, :group_name

      # @param [Hash] as_path,
      # @param [String] group_name
      def initialize(as_path: {}, group_name: '')
        @as_path = MddoBgpAsPath.new(**as_path)
        @group_name = group_name
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'as-path' => @as_path.topo_data,
          'group-name' => @group_name
        }
      end
    end

    # sub-data of as-path-set
    class MddoBgpAsPath
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] pattern
      #   @return [String]
      attr_accessor :name, :pattern

      # @param [String] name
      # @param [String pattern
      def initialize(name: '', pattern: '')
        @name = name
        @pattern = pattern
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'name' => @name,
          'pattern' => @pattern
        }
      end
    end

    # attribute for mddo-topology bgp-proc node bgp-policy: bgp-community-set
    class MddoBgpCommunitySet
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] communities
      #   @return [Array<String>]
      attr_accessor :name, :communities

      # @param [String] name
      # @param [Array<String>] communities
      def initialize(name: '', communities: [])
        @name = name
        @communities = communities.map { |c| MddoBgpCommunity.new(**c) }
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'name' => @name,
          'communities' => @communities.map(&:topo_data)
        }
      end
    end

    # sub-data of bgp-community-set
    class MddoBgpCommunity
      # @!attribute [rw] community
      #   @return [String]
      attr_accessor :community

      # @param [Hash] community_data
      # NOTE: community is single key-value hash
      #   like: `community = { 'community' => [String] }`
      def initialize(community_data)
        @community = community_data[:community]
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        { 'community' => @community }
      end
    end

    # attribute for mddo-topology bgp-proc node bgp-policy: bgp-policy
    class MddoBgpPolicy
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] default
      #   @return [MddoBgpPolicyDefaultStatement]
      # @!attribute [rw] statements
      #   @return [Array<MddoBgpPolicyStatement>]
      attr_accessor :name, :default, :statements

      # @param [String] name
      # @param [Array<Hash>] default
      # @param [Array<Hash>] statements
      def initialize(name: '', default: {}, statements: [])
        @name = name
        @default = MddoBgpPolicyDefaultStatement.new(**default)
        @statements = statements.map { |s| MddoBgpPolicyStatement.new(**s) }
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'name' => @name,
          'default' => @default.topo_data,
          'statements' => @statements.map(&:topo_data)
        }
      end
    end

    # sub-data of bgp-policy
    class MddoBgpPolicyDefaultStatement
      # @!attribute [rw] actions
      #   @return [Array<MddoBgpPolicyAction>]
      attr_accessor :actions

      # @param [Array<Hash>] actions
      def initialize(actions: [])
        @actions = actions.map { |a| MddoBgpPolicyAction.new(**a) }
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        { 'actions' => @actions.map(&:topo_data) }
      end
    end

    # sub-data of bgp-policy
    class MddoBgpPolicyStatement
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

      # @param [String] name
      # @param [Array<Hash>] actions
      # @param [Array<Hash>] conditions
      # @param [Hash] attrs (if-keyword: it cannot use as value name)
      def initialize(name: '', actions: [], conditions: [], **attrs)
        @name = name
        @actions = actions.map { |a| MddoBgpPolicyAction.new(**a) }
        @conditions = conditions.map { |c| MddoBgpPolicyCondition.new(**c) }
        @if = attrs.key?(:if) ? attrs[:if] : DEFAULT_IF_VALUE
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        data = {
          'name' => @name,
          'actions' => @actions.map(&:topo_data),
          'conditions' => @conditions.map(&:topo_data),
          'if' => @if
        }
        data.delete('if') if @if == DEFAULT_IF_VALUE
        data
      end
    end
  end
end
