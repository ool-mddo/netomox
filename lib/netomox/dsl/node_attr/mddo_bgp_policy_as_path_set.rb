# frozen_string_literal: true

module Netomox
  module DSL
    # attribute for mddo-topology bgp-proc node bgp-policy: bgp-as-path-set
    class MddoBgpAsPathSet
      # @!attribute [rw] as_path
      #   @return [Array<MddoBgpAsPathBase>]
      # @!attribute [rw] group_name
      #   @return [String]
      attr_accessor :as_path, :group_name

      # @param [Array<Hash>] as_path
      # @param [String] group_name
      def initialize(as_path: [], group_name: '')
        @as_path = convert_as_path(as_path)
        @group_name = group_name
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'as-path' => @as_path.map(&:topo_data),
          'group-name' => @group_name
        }
      end

      private

      # @param [Hash] data AS-path data
      # @return [Array<MddoBgpAsPathBase>] Converted as-path data
      def convert_as_path(data)
        converted_data = data.map do |v|
          if v.keys.include?(:pattern)
            MddoBgpAsPathPattern.new(**v)
          elsif v.keys.include?(:length)
            MddoBgpAsPathLength.new(**v)
          else
            Netomox.logger.error("Unknown as-path data: #{v}")
          end
        end
        converted_data.compact # remove unknown as-path data
      end
    end

    # sub-data of as-path-set
    class MddoBgpAsPathBase
      # @!attribute [rw] name
      #   @return [String]
      attr_accessor :name

      # @param [String] name
      def initialize(name)
        @name = name || ''
      end

      # Convert to RFC8345 topology data
      #   NOTE: will be override
      # @return [Hash]
      def topo_data
        { 'name' => @name }
      end
    end

    # sub-data of as-path-set, as-path
    class MddoBgpAsPathPattern < MddoBgpAsPathBase
      # @!attribute [rw] pattern
      #   @return [String]
      attr_accessor :pattern

      # @param [String] name
      # @param [String] pattern
      def initialize(name: '', pattern: '')
        super(name)
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

    # sub-data of as-path-set, as-path, length
    class MddoBgpAsPathLengthValue
      # @!attribute [rw] min
      #   @return [Integer]
      # @!attribute [rw] max
      #   @return [Integer]
      # @!attribute eq
      #   @return [Integer]
      attr_accessor :min, :max, :eq

      # @param [Hash] data AS-path length value
      def initialize(data)
        # default: invalid value (negative value)
        @min = -1
        @max = -1
        @eq = -1

        data.each_pair do |key, value|
          case key
          when :min
            @min = value.to_i
          when :max
            @max = value.to_i
          when :eq
            @eq = value.to_i
          else
            Netomox.logger.error "Unknown AS-Path length value keyword: #{key} in #{data}"
          end
        end
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        data = {}
        data['min'] = @min if @min.positive?
        data['max'] = @max if @max.positive?
        data['eq'] = @eq if @eq.positive?
        data
      end
    end

    # sub-data of os-path-set, as-path
    class MddoBgpAsPathLength < MddoBgpAsPathBase
      # @!attribute [rw] length
      #   @return []
      attr_accessor :length

      # @param [String] name
      # @param [Hash] length
      def initialize(name: '', length: {})
        super(name)
        @length = MddoBgpAsPathLengthValue.new(length)
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        {
          'name' => @name,
          'length' => @length.topo_data
        }
      end
    end
  end
end
