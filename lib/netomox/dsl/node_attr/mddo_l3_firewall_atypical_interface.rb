# frozen_string_literal: true

require 'netomox/const'

module Netomox
  module DSL
    # Fabric-specific options for a firewall atypical interface
    class MddoL3FirewallFabricOptions
      # @!attribute [rw] member_interfaces
      #   @return [Array<String>]
      attr_accessor :member_interfaces

      # @param [Array<String>] member_interfaces Member interface names
      def initialize(member_interfaces: [])
        @member_interfaces = member_interfaces
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        { 'member-interface' => @member_interfaces }
      end
    end

    # Atypical interface (fabric/control) on a firewall cluster node
    class MddoL3FirewallAtypicalInterface
      # @!attribute [rw] name
      #   @return [String]
      # @!attribute [rw] role
      #   @return [String] 'fabric' or 'control'
      # @!attribute [rw] fabric_options
      #   @return [MddoL3FirewallFabricOptions]
      attr_accessor :name, :role, :fabric_options

      # @param [String] name Interface name
      # @param [String] role 'fabric' or 'control'
      # @param [Hash] fabric_options Fabric-specific options (only for role='fabric')
      def initialize(name: '', role: '', fabric_options: {})
        @name = name
        @role = role
        @fabric_options = MddoL3FirewallFabricOptions.new(**fabric_options)
      end

      # Convert to RFC8345 topology data
      # @return [Hash]
      def topo_data
        data = { 'name' => @name, 'role' => @role }
        data['fabric-options'] = @fabric_options.topo_data if @role == 'fabric'
        data
      end
    end
  end
end
