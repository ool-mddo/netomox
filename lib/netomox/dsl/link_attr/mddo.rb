# frozen_string_literal: true

require 'netomox/const'

module Netomox
  module DSL
    # attribute base for mddo-topology link
    class MddoLinkAttributeBase
      # @param [Hash] _hash parameters (TBA)
      def initialize(_hash)
        @type = "#{NS_MDDO}:link-attributes"
      end

      # TBA
      # @return [Boolean]
      def empty?
        true
      end

      # TBA
      # @return [Hash]
      def topo_data
        {}
      end
    end

    # attribute for mddo-topology layer1 link
    class MddoL1LinkAttribute < MddoLinkAttributeBase
      def initialize(hash)
        super
        @type = "#{NS_MDDO}:l1-link-attributes"
      end
    end

    # attribute for mddo-topology layer2 link
    class MddoL2LinkAttribute < MddoLinkAttributeBase
      def initialize(hash)
        super
        @type = "#{NS_MDDO}:l2-link-attributes"
      end
    end

    # attribute for mddo-topology layer3 link
    class MddoL3LinkAttribute < MddoLinkAttributeBase
      def initialize(hash)
        super
        @type = "#{NS_MDDO}:l3-link-attributes"
      end
    end

    # attribute for mddo-topology ospf-area link
    class MddoOspfAreaLinkAttribute < MddoLinkAttributeBase
      def initialize(hash)
        super
        @type = "#{NS_MDDO}:ospf-area-link-attributes"
      end
    end

    # attribute for mddo-topology bgp-proc link
    class MddoBgpProcLinkAttribute < MddoLinkAttributeBase
      def initialize(hash)
        super
        @type = "#{NS_MDDO}:bgp-proc-link-attributes"
      end
    end

    # attribute for mddo-topology bgp-as link
    class MddoBgpAsLinkAttribute < MddoLinkAttributeBase
      def initialize(hash)
        super
        @type = "#{NS_MDDO}:bgp-as-link-attributes"
      end
    end
  end
end
