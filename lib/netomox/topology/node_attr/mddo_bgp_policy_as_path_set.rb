# frozen_string_literal: true

module Netomox
  module Topology
    # as-path-set for bgp-policy
    class MddoBgpAsPathSet < SubAttributeBase
      # @!attribute [rw] as_path
      #   @return [Array<MddoBgpAsPath>]
      # @!attribute [rw] group_name
      #   @return [String]
      attr_accessor :as_path, :group_name

      # Attribute defs
      ATTR_DEFS = [
        { int: :as_path, ext: 'as-path', default: [] },
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
      # @return [Array<MddoBgpAsPathBase>] Converted attribute data
      def convert_as_path(data)
        key = @attr_table.ext_of(:as_path)
        return [] unless operative_array_key?(data, key)

        converted_data = data[key].map do |d|
          if d.keys.include?('pattern')
            MddoBgpAsPathPattern.new(d, key)
          elsif d.keys.include?('length')
            MddoBgpAsPathLength.new(d, key)
          else
            Netomox.logger.error("Unknown as-path data: #{d}")
          end
        end
        converted_data.compact # remove unknown as-path data
      end
    end

    # sub-data of as-path-set
    class MddoBgpAsPathBase < SubAttributeBase
      # abstract class
    end

    # sub-data of as-path-set, as-path
    class MddoBgpAsPathPattern < MddoBgpAsPathBase
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

    # sub-data of as-path-set, as-path, length
    class MddoBgpAsPathLengthValue < SubAttributeBase
      # @!attribute [rw] min
      #   @return [Integer]
      # @!attribute [rw] max
      #   @return [Integer]
      # @!attribute [rw] eq
      #   @return [Integer]
      attr_accessor :min, :max, :eq

      # Attribute defs
      ATTR_DEFS = [
        { int: :min, ext: 'min', default: -1, convert: ->(d) { d.to_i } },
        { int: :max, ext: 'max', default: -1, convert: ->(d) { d.to_i } },
        { int: :eq, ext: 'eq', default: -1, convert: ->(d) { d.to_i } }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # NOTE: override
      # Convert to data for RFC8345 format
      # @return [Hash]
      def to_data
        data = super
        # NOTE: removed unused key
        data.delete_if { |_key, value| value.negative? }
      end
    end

    # sub-data of as-path-set, as-path
    class MddoBgpAsPathLength < MddoBgpAsPathBase
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] length
      #   @return [String]
      attr_accessor :name, :length

      # Attribute defs
      ATTR_DEFS = [
        { int: :name, ext: 'name', default: '' },
        { int: :length, ext: 'length', default: '' }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        @length = convert_length_value(data)
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [MddoBgpAsPathLengthValue] Converted attribute data
      def convert_length_value(data)
        key = @attr_table.ext_of(:length)
        MddoBgpAsPathLengthValue.new(operative_hash_key?(data, key) ? data[key] : {}, key)
      end
    end
  end
end
