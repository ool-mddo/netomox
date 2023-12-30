# frozen_string_literal: true

require 'netomox/topology/attr_base'

module Netomox
  module Topology
    # sub-data of bgp-policy-statement
    class MddoBgpPolicyCondition < SubAttributeBase; end

    # condition: protocol
    class MddoBgpPolicyConditionProtocol < MddoBgpPolicyCondition
      # @!attribute [rw] protocol
      #   @return [String]
      attr_accessor :protocol

      # Attribute defs
      ATTR_DEFS = [{ int: :protocol, ext: 'protocol', default: '' }].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end
    end

    # condition: rib
    class MddoBgpPolicyConditionRib < MddoBgpPolicyCondition
      # @!attribute [rw] rib
      #   @return [String]
      attr_accessor :rib

      # Attribute defs
      ATTR_DEFS = [{ int: :rib, ext: 'rib', default: '' }].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end
    end

    # condition: route-filter
    class MddoBgpPolicyConditionRouteFilter < MddoBgpPolicyCondition
      # @!attribute [rw] route_filter
      #   @return [MddoBgpPolicyConditionRouteFilterBody]
      attr_accessor :route_filter

      # Attribute defs
      ATTR_DEFS = [{ int: :route_filter, ext: 'route-filter', default: {} }].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        @route_filter = convert_route_filter(data)
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [MddoBgpPolicyConditionRouteFilterBody] Converted attribute data
      def convert_route_filter(data)
        key = @attr_table.ext_of(:route_filter)
        MddoBgpPolicyConditionRouteFilterBody.new(data[key], key)
      end
    end

    # condition: policy
    class MddoBgpPolicyConditionPolicy < MddoBgpPolicyCondition
      # @!attribute [rw] policy
      #   @return [String]
      attr_accessor :policy

      # Attribute defs
      ATTR_DEFS = [{ int: :policy, ext: 'policy', default: '' }].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end
    end

    # condition: as-path-group
    class MddoBgpPolicyConditionAsPathGroup < MddoBgpPolicyCondition
      # @!attribute [rw] as_path_group
      #   @return [String]
      attr_accessor :as_path_group

      # Attribute defs
      ATTR_DEFS = [{ int: :as_path_group, ext: 'as-path-group', default: '' }].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end
    end

    # condition: community
    class MddoBgpPolicyConditionCommunity < MddoBgpPolicyCondition
      # @!attribute [rw] communities
      #   @return [Array<String>]
      attr_accessor :communities

      # Attribute defs
      ATTR_DEFS = [{ int: :communities, ext: 'community', default: [] }].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end
    end

    # condition: prefix-list-filter
    class MddoBgpPolicyConditionPrefixListFilter < MddoBgpPolicyCondition
      # @!attribute [rw] prefix_list_filter
      #   @return [MddoBgpPolicyPrefixListFilter]
      attr_accessor :prefix_list_filter

      # Attribute defs
      ATTR_DEFS = [{ int: :prefix_list_filter, ext: 'prefix-list-filter', default: {} }].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        @prefix_list_filter = convert_prefix_list_filter(data)
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [MddoBgpPolicyPrefixListFilter] Converted attribute data
      def convert_prefix_list_filter(data)
        key = @attr_table.ext_of(:prefix_list_filter)
        MddoBgpPolicyPrefixListFilter.new(data[key], key)
      end
    end

    # sub-data of bgp-policy-condition
    class MddoBgpPolicyConditionRouteFilterBody < SubAttributeBase
      # @!attribute [rw] length
      #   @return [MddoBgpPolicyConditionRFLength]
      # @!attribute [rw] match_type
      #   @return [String]
      # @!attribute [rw] prefix
      #   @return [String]
      attr_accessor :length, :match_type, :prefix

      # Attribute defs
      ATTR_DEFS = [
        { int: :length, ext: 'length', default: {} },
        { int: :match_type, ext: 'match-type', default: '' },
        { int: :prefix, ext: 'prefix', default: '' }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        @length = convert_condition_rf_length(data)
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [MddoBgpPolicyConditionRFLength] Converted attribute data
      def convert_condition_rf_length(data)
        key = @attr_table.ext_of(:length)
        MddoBgpPolicyConditionRFLength.new(data[key], key)
      end
    end

    # sub-data of bgp-policy-condition
    class MddoBgpPolicyPrefixListFilter < SubAttributeBase
      # @!attribute [rw] match_type
      #   @return [String]
      # @!attribute [rw] prefix_list A name of prefix-set
      #   @return [String]
      attr_accessor :match_type, :prefix_list

      # Attribute defs
      ATTR_DEFS = [
        { int: :match_type, ext: 'match-type', default: '' },
        { int: :prefix_list, ext: 'prefix-list', default: '' }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end
    end

    # sub-data of bgp-policy-condition-route-filter (Route-Filter-Length)
    class MddoBgpPolicyConditionRFLength < SubAttributeBase
      # @!attribute [rw] max
      #   @return [Integer]
      # @!attribute [rw] min
      #   @return [Integer]
      attr_accessor :max, :min

      # Attribute defs
      ATTR_DEFS = [
        { int: :min, ext: 'min', default: -1 },
        { int: :max, ext: 'max', default: -1 }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [Boolean]
      def empty?
        @min.negative? && @max.negative?
      end

      # @return [Hash]
      def to_data
        empty? ? {} : super
      end
    end
  end
end
