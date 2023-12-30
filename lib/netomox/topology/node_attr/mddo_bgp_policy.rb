# frozen_string_literal: true

require 'netomox/topology/attr_base'

module Netomox
  module Topology
    # prefix-set for bgp-policy
    class MddoBgpPrefixSet < AttributeBase
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

    # as-path-set for bgp-policy
    class MddoBgpAsPathSet < AttributeBase
      # @!attribute [rw] as_path
      #   @return [MddoBgpAsPath]
      # @!attribute [rw] group_name
      #   @return [String]
      attr_accessor :as_path, :group_name

      # Attribute defs
      ATTR_DEFS = [
        { int: :as_path, ext: 'as-path', default: {} },
        { int: :group_name, ext: 'group-name', default: '' }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        @as_path = convert_as_path(data)
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [MddoBgpAsPath] Converted attribute data
      def convert_as_path(data)
        key = @attr_table.ext_of(:as_path)
        MddoBgpAsPath.new(data[key], key)
      end
    end

    # sub-data of as-path-set
    class MddoBgpAsPath < SubAttributeBase
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] pattern
      #   @return [String]
      attr_accessor :name, :pattern

      # Attribute defs
      ATTR_DEFS = [
        { int: :name, ext: 'name', default: '' },
        { int: :pattern, ext: 'pattern', default: '' }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end
    end

    # bgp-community-set for bgp-policy
    class MddoBgpCommunitySet < AttributeBase
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
  end
end
