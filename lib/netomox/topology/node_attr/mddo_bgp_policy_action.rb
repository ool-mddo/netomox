# frozen_string_literal: true

require 'netomox/topology/attr_base'

module Netomox
  module Topology
    # base class of action of bgp-policy
    class MddoBgpPolicyAction < SubAttributeBase; end

    # action: target
    class MddoBgpPolicyActionTarget < MddoBgpPolicyAction
      # @!attribute [rw] target
      #   @return [String]
      attr_accessor :target

      # Attribute defs
      ATTR_DEFS = [{ int: :target, ext: 'target', default: '' }].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end
    end

    # action: community
    class MddoBgpPolicyActionCommunity < MddoBgpPolicyAction
      # @!attribute [rw] community
      #   @return [MddoBgpPolicyActionCommunity]
      attr_accessor :community

      # Attribute defs
      ATTR_DEFS = [{ int: :community, ext: 'community', default: {} }].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
        @community = convert_community(data)
      end

      private

      # @param [Hash] data Attribute data (RFC8345)
      # @return [MddoBgpPolicyActionCommunityBody] Converted attribute data
      def convert_community(data)
        key = @attr_table.ext_of(:community)
        MddoBgpPolicyActionCommunityBody.new(data, key)
      end
    end

    # action next-hop
    class MddoBgpPolicyActionNextHop < MddoBgpPolicyAction
      # @!attribute [rw] next_hop
      #   @return [String]
      attr_accessor :next_hop

      # Attribute defs
      ATTR_DEFS = [{ int: :next_hop, ext: 'next-hop', default: '' }].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end
    end

    # action: local-preference
    class MddoBgpPolicyActionLocalPreference < MddoBgpPolicyAction
      # @!attribute [rw] local_preference
      #   @return [Integer]
      attr_accessor :local_preference

      # Attribute defs
      ATTR_DEFS = [{ int: :local_preference, ext: 'local-preference', default: '' }].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end
    end

    # action: metric
    class MddoBgpPolicyActionMetric < MddoBgpPolicyAction
      # @!attribute [rw] metric
      #   @return [Integer]
      attr_accessor :metric

      # Attribute defs
      ATTR_DEFS = [{ int: :metric, ext: 'metric', default: -1 }].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end
    end

    # sub-data of bgp-policy-action
    class MddoBgpPolicyActionCommunityBody < SubAttributeBase
      # @!attribute [rw] action
      #   @return [String]
      # @!attribute [rw] name
      #   @return [String]
      attr_accessor :action, :name

      # Attribute defs
      ATTR_DEFS = [
        { int: :action, ext: 'action', default: '' },
        { int: :name, ext: 'name', default: '' }
      ].freeze

      # @param [Hash] data Attribute data (RFC8345)
      # @param [String] type Attribute type (keyword of data in RFC8345)
      def initialize(data, type)
        super(ATTR_DEFS, data, type)
      end
    end
  end
end
