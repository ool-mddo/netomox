# frozen_string_literal: true

module Netomox
  module Topology
    # one record of attribute table
    class AttributeTableLine
      # @!attribute [r] int
      #   @return [Symbol]
      # @!attribute [r] ext
      #   @return [String]
      # @!attribute [r] default
      #   @return [Object]
      # @!attribute [r] empty_check
      #   @return [Symbol]
      # @!attribute [r] convert
      #   @return [Proc]
      attr_reader :int, :ext, :default, :empty_check, :convert

      # @param [Symbol] int Internal attribute keyword (as property/method name)
      # @param [String] ext External attribute keyword (for YANG or other data files)
      # @param [String] default [optional] Default value
      # @param [Proc] convert [optional] convert function (single-argument function)
      def initialize(int:, ext:, default: '', convert: ->(d) { d })
        @int = int
        @ext = ext
        @default = default
        # convert function: when accept Integer and String value
        # e.g.: accept "42" and 42 as 42 : convert = ->(d) { d.to_i }
        # default function is identity function (it outputs input object)
        @convert = convert
        @empty_check = select_empty_check_method
      end

      private

      # @return [Symbol, FalseClass] empty check method (false to ignore empty-checking)
      def select_empty_check_method
        case @default
        when Array, Hash, String then :empty?
        when Integer then :zero?
        else false # ignore empty check
        end
      end
    end

    # attribute key table/converter
    class AttributeTable
      # @param [Array<Hash>] lines Attribute definition data table
      def initialize(lines)
        # lines = [
        #   {
        #     int: :AttributeBase_member_name,
        #     ext: 'JSON-key-name',
        #     default: default_value
        #   },
        #   ....
        # ]
        @lines = lines.map { |line| AttributeTableLine.new(**line) }
      end

      # @return [Array<Symbol>] Internal keys (variable names of attribute)
      def int_keys
        @lines.map(&:int)
      end

      # @return [Array<Symbol>] Internal keys (to check except empty)
      def int_keys_with_empty_check
        keys = @lines.find_all(&:empty_check)
        keys.map(&:int)
      end

      # @param [Symbol] int_key Internal keyword
      # @return [String] external keyword of int_key
      def ext_of(int_key)
        find_line_by(int_key).ext
      end

      # @param [Symbol] int_key Internal keyword
      # @return [String] default value of int_key
      def default_of(int_key)
        find_line_by(int_key).default
      end

      # @param [Symbol] int_key Internal keyword
      # @return [Proc] convert function
      def convert_of(int_key)
        find_line_by(int_key).convert
      end

      # @param [Symbol] int_key Internal keyword
      # @return [Symbol] Method to check empty
      # @return [Boolean] false if the attribute does not have empty check method
      def check_of(int_key)
        find_line_by(int_key).empty_check
      end

      # @param [Symbol] int_key Internal keyword
      # @return [AttributeTableLine]
      def find_line_by(int_key)
        @lines.find { |d| d.int == int_key }
      end
    end
  end
end
