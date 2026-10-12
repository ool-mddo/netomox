# frozen_string_literal: true

require 'netomox/dsl/base'
require 'netomox/dsl/network'
require 'netomox/dsl/network_attr/mddo'

module Netomox
  module DSL
    # multiple network container (top)
    class Networks < DSLObjectBase
      # @!attribute [rw] networks
      #   @return [Array<Network>]
      attr_accessor :networks

      # @yield Code block to eval this instance
      # @yieldreturn [void]
      def initialize(&block)
        super(nil, 'networks')
        @networks = []
        @attribute = nil
        register(&block) if block_given?
      end

      # Add or access network by name
      # @param [String] name Network name
      # @yield Code block to eval the network
      # @yieldreturn [void]
      # @return [Network]
      def network(name, &block)
        nw = find_network(name)
        if nw
          nw.register(&block) if block_given?
        else
          nw = Network.new(self, name, &block)
          @networks.push(nw)
        end
        nw
      end

      # Set attribute of the networks container (mddo augmentation)
      # @param [Hash] attr Attribute data (e.g. `flags: %w[key=value]`)
      # @return [MddoNetworksNWAttribute]
      def attribute(attr)
        @attribute = MddoNetworksNWAttribute.new(**attr)
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        nws_data = {}
        nws_data[@attribute.type] = @attribute.topo_data if @attribute && !@attribute.empty?
        nws_data['network'] = @networks.map(&:topo_data)
        { "#{NS_NW}:networks" => nws_data }
      end

      # Find network by name
      # @param [String] name Network name
      # @return [Network, nil] Found network (nil if not found)
      def find_network(name)
        @networks.find { |nw| nw.name == name }
      end
    end
  end
end
