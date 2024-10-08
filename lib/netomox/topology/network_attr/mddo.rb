# frozen_string_literal: true

require 'netomox/topology/network_attr/base'

module Netomox
  module Topology
    # attribute for L1 network
    class MddoL1NetworkAttribute < NetworkAttributeBase
      def initialize(data, type)
        super([], data, type) # same as Parent
      end
    end

    # attribute for L2 network
    class MddoL2NetworkAttribute < NetworkAttributeBase
      def initialize(data, type)
        super([], data, type) # same as Parent
      end
    end

    # attribute for L3 network
    class MddoL3NetworkAttribute < NetworkAttributeBase
      def initialize(data, type)
        super([], data, type) # same as Parent
      end
    end

    # attribute for ospf-area network
    class MddoOspfAreaNetworkAttribute < NetworkAttributeBase
      # @!attribute [rw] identifier
      #   @return [String]
      #   @note dotted-quad string
      attr_accessor :identifier

      # Attribute definition of network
      # NOTE: identifier variation: integer(0) for cisco, string('0.0.0.0') for junos
      ATTR_DEFS = [{ int: :identifier, ext: 'identifier', default: '' }].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end

      # @return [String]
      def to_s
        "attribute: area:#{@identifier}, #{@name}, #{@flags}"
      end
    end

    # attribute for bgp-proc network
    class MddoBgpProcNetworkAttribute < NetworkAttributeBase
      def initialize(data, type)
        super([], data, type) # same as Parent
      end

      # @return [String]
      def to_s
        "attribute: #{@name}, #{@flags}"
      end
    end

    # attribute for bgp-as network
    class MddoBgpAsNetworkAttribute < NetworkAttributeBase
      def initialize(data, type)
        super([], data, type) # same as Parent
      end

      # @return [String]
      def to_s
        "attribute: #{@name}, #{@flags}"
      end
    end
  end
end
