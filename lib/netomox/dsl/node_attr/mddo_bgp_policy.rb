# frozen_string_literal: true

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
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] actions
      #   @return [Array<MddoBgpPolicyAction>]
      # @!attribute [rw] conditions
      #   @return [Array<MddoBgpPolicyCondition>]
      # @!attribute [rw] if
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
        @if = attrs.key?(:if) ? attrs[:if] : '__UNKNOWN__'
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'name' => @name,
          'actions' => @actions.map(&:topo_data),
          'conditions' => @conditions.map(&:topo_data),
          'if' => @if
        }
      end
    end

    # sub-data of bgp-policy and bgp-policy-statement
    class MddoBgpPolicyAction
      # @!attribute [rw] key
      #   @return [String]
      # @!attribute [rw] value
      #   @return [Integer, String. MddoBgpPolicyActionCommunity]
      attr_accessor :key, :value

      # @param [Hash] action
      # NOTE: action is single key-value hash
      #   like `action = { key => [Integer, String, Hash] }`
      def initialize(action)
        @key = action.keys[0]

        value = action[@key]
        @value = case @key.downcase.to_sym
                 when :community
                   MddoBgpPolicyActionCommunity.new(**value)
                 else
                   value
                 end
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          @key.to_s.gsub('_', '-') => @value.respond_to?(:topo_data) ? @value.topo_data : @value
        }
      end
    end

    # sub-data of bgp-policy-statement
    class MddoBgpPolicyCondition
      # @!attribute [rw] key
      #   @return [String]
      # @!attribute [rw] value
      #   @return [String, MddoBgpPolicyConditionRouteFilter, BgpPolicyPrefixListFilter, Array<String>]
      attr_accessor :key, :value

      # @param [Hash] condition
      # NOTE: condition is single key-value hash
      #   like `condition = { key => [String, Hash, Array<String>] }`
      def initialize(condition)
        @key = condition.keys[0]

        value = condition[@key]
        @value = case @key.downcase.to_sym
                 when :route_filter
                   MddoBgpPolicyConditionRouteFilter.new(**value)
                 when :prefix_list_filter
                   MddoBgpPolicyConditionPrefixListFilter.new(**value)
                 else
                   value
                 end
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          @key.to_s.gsub('_', '-') => @value.respond_to?(:topo_data) ? @value.topo_data : @value
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
