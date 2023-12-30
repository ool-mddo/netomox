# frozen_string_literal: true

module Netomox
  module DSL
    # attribute for mddo-topology bgp-proc node bgp-policy: prefix-set
    class BgpPrefixSet
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] prefixes
      #   @return [Array<String>]
      attr_accessor :name, :prefixes

      # @param [String] name
      # @param [Array<String>] prefixes
      def initialize(name: '', prefixes: [])
        @name = name
        @prefixes = prefixes.map { |p| BgpPrefix.new(**p) }
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
    class BgpPrefix
      # @!attribute [rw] key
      #   @return [String]
      # @!attribute [rw] value
      #   @return [String]
      attr_accessor :key, :value

      # @param [Hash] prefix
      # NOTE: prefix is single key-value hash
      #   like: `prefix = { 'prefix' => 'x.x.x.x/nn' }`
      def initialize(prefix)
        @key = :prefix
        @value = prefix[@key]
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        { 'prefix' => @value }
      end
    end

    # attribute for mddo-topology bgp-proc node bgp-policy: bgp-as-path-set
    class BgpAsPathSet
      # @!attribute [rw] as_path
      #   @return [BgpAsPath]
      # @!attribute [rw] group_name
      #   @return [String]
      attr_accessor :as_path, :group_name

      # @param [Hash] as_path,
      # @param [String] group_name
      def initialize(as_path: {}, group_name: '')
        @as_path = BgpAsPath.new(**as_path)
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
    class BgpAsPath
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
    class BgpCommunitySet
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] communities
      #   @return [Array<String>]
      attr_accessor :name, :communities

      # @param [String] name
      # @param [Array<String>] communities
      def initialize(name: '', communities: [])
        @name = name
        @communities = communities.map { |c| BgpCommunity.new(**c) }
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
    class BgpCommunity
      # @!attribute [rw] key
      #   @return [String]
      # @!attribute [rw] value
      #   @return [String]
      attr_accessor :key, :value

      # @param [Hash] community
      # NOTE: community is single key-value hash
      #   like: `community = { 'community' => [String] }`
      def initialize(community)
        @key = :community
        @value = community[@key]
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        { 'community' => @value }
      end
    end

    # attribute for mddo-topology bgp-proc node bgp-policy: bgp-policy
    class BgpPolicy
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] default
      #   @return [BgpPolicyDefaultStatement]
      # @!attribute [rw] statements
      #   @return [Array<BgpPolicyStatement>]
      attr_accessor :name, :default, :statements

      # @param [String] name
      # @param [Array<Hash>] default
      # @param [Array<Hash>] statements
      def initialize(name: '', default: {}, statements: [])
        @name = name
        @default = BgpPolicyDefaultStatement.new(**default)
        @statements = statements.map { |s| BgpPolicyStatement.new(**s) }
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
    class BgpPolicyDefaultStatement
      # @!attribute [rw] actions
      #   @return [Array<BgpPolicyAction>]
      attr_accessor :actions

      # @param [Array<Hash>] actions
      def initialize(actions: [])
        @actions = actions.map { |a| BgpPolicyAction.new(**a) }
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        { 'actions' => @actions.map(&:topo_data) }
      end
    end

    # sub-data of bgp-policy
    class BgpPolicyStatement
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] actions
      #   @return [Array<BgpPolicyAction>]
      # @!attribute [rw] conditions
      #   @return [Array<BgpPolicyCondition>]
      # @!attribute [rw] if
      #   @return [String]
      attr_accessor :name, :actions, :conditions, :if

      # @param [String] name
      # @param [Array<Hash>] actions
      # @param [Array<Hash>] conditions
      # @param [Hash] attrs (if-keyword: it cannot use as value name)
      def initialize(name: '', actions: [], conditions: [], **attrs)
        @name = name
        @actions = actions.map { |a| BgpPolicyAction.new(**a) }
        @conditions = conditions.map { |c| BgpPolicyCondition.new(**c) }
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
    class BgpPolicyAction
      # @!attribute [rw] key
      #   @return [String]
      # @!attribute [rw] value
      #   @return [Integer, String. BgpPolicyActionCommunity]
      attr_accessor :key, :value

      # @param [Hash] action
      # NOTE: action is single key-value hash
      #   like `action = { key => [Integer, String, Hash] }`
      def initialize(action)
        @key = action.keys[0]

        value = action[@key]
        @value = case @key.downcase.to_sym
                 when :community
                   BgpPolicyActionCommunity.new(**value)
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
    class BgpPolicyCondition
      # @!attribute [rw] key
      #   @return [String]
      # @!attribute [rw] value
      #   @return [String, BgpPolicyConditionRouteFilter, BgpPolicyPrefixListFilter, Array<String>]
      attr_accessor :key, :value

      # @param [Hash] condition
      # NOTE: condition is single key-value hash
      #   like `condition = { key => [String, Hash, Array<String>] }`
      def initialize(condition)
        @key = condition.keys[0]

        value = condition[@key]
        @value = case @key.downcase.to_sym
                 when :route_filter
                   BgpPolicyConditionRouteFilter.new(**value)
                 when :prefix_list_filter
                   BgpPolicyPrefixListFilter.new(**value)
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
    class BgpPolicyActionCommunity
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
    class BgpPolicyConditionRouteFilter
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
    class BgpPolicyPrefixListFilter
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

      # @param [Integer] max
      # @param [Integer] min
      def initialize(min: -1, max: -1)
        @min = min
        @max = max
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
