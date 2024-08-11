# frozen_string_literal: true

require 'netomox/topology/attr_base'
require 'netomox/topology/diff_state'
require 'netomox/topology/attr_table'

module Netomox
  # RFC8345 Topology data parser
  module Topology
    # Base of sub-attribute class (doesn't have diff_state)
    class SubAttributeBase
      # @!attribute [r] keys
      #   @return [Object]
      attr_reader :keys
      # @!attribute [rw] path
      #   @return [String]
      # @!attribute [rw] type
      #   @return [String]
      attr_accessor :path, :type

      # @param [Array<Hash>] attr_table Attribute data
      # @param [Hash] data Attribute data (RFC8345 external_key:value)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(attr_table, data, type)
        @attr_table = AttributeTable.new(attr_table)
        @keys = @attr_table.int_keys
        @keys_with_empty_check = @attr_table.int_keys_with_empty_check
        @path = 'attribute' # TODO: dummy for #to_data pair
        @type = type
        setup_members(data)
      end

      # @return [Boolean]
      def empty?
        return true if @type == '_empty_attr_'
        return false if @keys_with_empty_check.empty?

        @keys_with_empty_check.all? do |k|
          # send(k) -> attribute value
          # @attr_table.check_of(k) -> method name to check empty/zero
          send(k).send(@attr_table.check_of(k))
        end
      end

      # @param [Symbol] key Attribute to check existence
      # @return [Boolean]
      def attribute?(key)
        self.class.method_defined?(key)
      end

      # @param [AttributeBase] other
      # @return [Boolean] true if all values of members(keys) are same
      def eql?(other)
        return false unless self.class.name == other.class.name

        @keys.all? { |k| send(k) == other.send(k) }
      end
      alias == eql?

      # @return [String]
      def to_s
        '## AttributeBase#to_s MUST override in sub class ##'
      end

      # attribute class has #diff method or not?
      # when attribute has sub-attribute, define #diff method in sub class.
      # @return [Boolean]
      def diff?
        self.class.instance_methods.include?(:diff)
      end

      # attribute class has #fill method or not?
      # @return [Boolean]
      def fill?
        self.class.instance_methods.include?(:fill)
      end

      # Convert to data for RFC8345 format
      # @return [Hash]
      def to_data
        data = {}
        @keys.each do |k|
          attr = select_child_attr(send(k))
          ext_key = @attr_table.ext_of(k)
          data[ext_key] = attr
        end
        data
      end

      # @param [Symbol] int_key Internal attribute key
      # @return [Boolean]
      def key?(int_key)
        @keys.include?(int_key)
      end

      # @param [Symbol] int_key Internal attribute key
      # @return [Object] Value of the key
      #   NOTICE: If it key has sub-attribute class instance, return the raw attribute instance
      #   NOT #topo_data (converted topology data)
      def [](int_key)
        send(int_key)
      end

      # @param [Symbol] int_key Internal attribute key
      # @param [Object] value New value of the key
      # @return [Object] New value
      def []=(int_key, value)
        send("#{int_key}=", value)
      end

      protected

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] ext_key External-key of attribute-table record
      # @return [Boolean] true if the key exists in the data and not nil
      def operative_key?(data, ext_key)
        data.key?(ext_key) && !data[ext_key].nil?
      end

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] ext_key External-key of attribute-table record
      # @return [Boolean] true if the key exists in the data and its value is an array.
      def operative_array_key?(data, ext_key)
        operative_key?(data, ext_key) && data[ext_key].is_a?(Array)
      end

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] ext_key External-key of attribute-table record
      # @return [Boolean] true if the key exists in the data and its value is an hash.
      def operative_hash_key?(data, ext_key)
        operative_key?(data, ext_key) && data[ext_key].is_a?(Hash)
      end

      private

      # convert attribute instance to data (#to_data)
      # @param [Array, AttributeBase, Hash] attr An attribute
      # @return [Array<Hash>, Hash] RFC8345 converted data
      def select_child_attr(attr)
        if attr.is_a?(Array) && attr.all? { |d| d.is_a?(SubAttributeBase) }
          # for sub-attribute array
          attr.map(&:to_data)
        elsif attr.is_a?(SubAttributeBase)
          # for single sub-attribute
          attr.to_data
        else
          # literal array or hash
          attr
        end
      end

      # @param [Object] value
      # @return [Boolean] true if the value is Integer or String
      def int_or_str?(value)
        value.instance_of?(Integer) || value.instance_of?(String)
      end

      # @param [String] ext_key External key of the attribute
      # @param [Object] default_value
      # @param [Object] value
      # @return [void]
      def members_value_type_check(ext_key, default_value, value)
        return if default_value.instance_of?(value.class)

        message = "Attribute type mismatch: key=#{ext_key}, " \
                  "default=`#{default_value}`(#{default_value.class.name}), value=`#{value}`(#{value.class.name})"
        if int_or_str?(default_value) && int_or_str?(value)
          # tolerate differences between strings and integers.
          Netomox.logger.warn message
        else
          # others are error
          Netomox.logger.error message
        end
      end

      # setup attribute members (keys) value according to @attr_table definition
      # @param [Hash] data RFC8345 data (attribute)
      # @return [void]
      def setup_members(data)
        # define member (attribute) of the class
        # according to @attr_table (ATTR_DEFS in sub-classes of AttributeBase)
        @keys.each do |int_key|
          ext_key = @attr_table.ext_of(int_key)
          default = @attr_table.default_of(int_key)
          value = data[ext_key] || default
          # value convert e.g.: "42" -> 42 if it have to handle both Integer and String as input
          value = @attr_table.convert_of(int_key).call(value)
          # type check
          members_value_type_check(ext_key, default, value)
          # assignment action
          send("#{int_key}=", value)
        end
      end
    end

    # Base class for attribute (have diff_state)
    class AttributeBase < SubAttributeBase
      # @!attribute [rw] diff_state
      #   @return [DiffState]
      attr_accessor :diff_state

      def initialize(attr_table, data, type)
        super(attr_table, data, type)
        @diff_state = DiffState.new # empty state
      end

      def to_data
        data = super
        data['_diff_state_'] = @diff_state.to_data
        data
      end
    end
  end
end
