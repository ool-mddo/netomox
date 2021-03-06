# frozen_string_literal: true

require 'yaml'
require_relative 'bf_wrapper_query_base'

module TopologyOperator
  # Reachability-test pattern handler
  class ReachPatternHandler < BFWrapperQueryBase
    # @param [String] pattern_file Test pattern file name (yaml)
    def initialize(pattern_file)
      super()
      data = YAML.load_file(pattern_file)
      @env_table = data['environment']
      @group_table = data['groups']
      @patterns = data['patterns']
      validate_environment
      @intf_list = fetch_interface_list
      validate_keys_in_patterns
      validate_node_intf_in_groups
    end

    # @return [Array<Hash>]
    def expand_patterns
      @patterns.map do |pair|
        {
          pattern: pair,
          cases: expand_cases(@group_table[pair[0]], @group_table[pair[1]])
        }
      end
    end

    private

    # @return [void]
    def validate_environment
      networks = fetch_networks
      unless networks.include?(@env_table['network'])
        warn "Error: network:#{@env_table['network']} is not found in batfish"
        exit 1
      end

      snapshots = fetch_snapshots(@env_table['network'])
      return if snapshots.include?(@env_table['snapshot'])

      warn "Error: snapshot:#{@env_table['snapshot']} is not found in network #{@env_table['network']}"
      exit 1
    end

    # @param [String] intf_path "node__interface" format string (interface path)
    # @return [Hash]
    def intf_path_to_hash(intf_path)
      node, intf = intf_path_to_names(intf_path)
      {
        node: node,
        intf: intf,
        intf_ip: find_intf_ip(node, intf)
      }
    end

    # @param [Array<String>] src_intf_paths List of interface-path (source set)
    # @param [Array<String>] dst_intf_paths List of interface-path (destination set)
    # @return [Array<Hash>]
    def expand_cases(src_intf_paths, dst_intf_paths)
      src_intf_paths.product(dst_intf_paths).map do |intf_paths|
        # prod => [node__intf, node__intf]
        {
          src: intf_path_to_hash(intf_paths[0]),
          dst: intf_path_to_hash(intf_paths[1])
        }
      end
    end

    # @param [String] node Node name
    # @param [String] intf Interface name
    # @return [String] ip address of the interface (empty-string if the interface does not have ip addr)
    def find_intf_ip(node, intf)
      bf_intf = find_intf_in_node(node, intf)
      bf_intf.empty? ? '' : bf_intf['addresses'][0]
    end

    # @param [String] intf_path "node__interface" format string (interface path)
    # @return [Array<String, String>] node and interface (empty-array if intf_path is incorrect format)
    def intf_path_to_names(intf_path)
      return [] unless intf_path =~ /(.+)__(.+)/

      [Regexp.last_match[1], Regexp.last_match[2]]
    end

    # @return [void]
    def validate_keys_in_patterns
      found_error = false
      @patterns.each do |pair|
        pair.each do |group_key|
          next if @group_table.key?(group_key)

          warn "Key:#{group_key} is not found in groups"
          found_error = true
        end
      end
      exit 1 if found_error
    end

    # @param [String] node Node name to search
    # @return [Array<Hash>]
    def find_all_intfs_of_node(node)
      @intf_list.find_all { |intf_item| intf_item['node'] == node }
    end

    # @param [String] node Node name
    # @param [String] intf Interface name to find
    # @return [Hash, nil]
    def find_intf_in_node(node, intf)
      find_all_intfs_of_node(node).find { |intf_item| intf_item['interface'] == intf }
    end

    # rubocop:disable Metrics/MethodLength

    # return [void]
    def validate_node_intf_in_groups
      found_error = false
      @group_table.each_pair do |grp_key, intf_paths|
        intf_paths.each do |intf_path|
          names = intf_path_to_names(intf_path)
          if names.empty?
            warn "Error: intf:#{intf_path} in #{grp_key} is incorrect format"
            found_error = true
            next
          end

          node, intf = names
          unless find_all_intfs_of_node(node)
            warn "Error: node:#{node} is not found in #{grp_key}"
            found_error = true
            next
          end
          next if find_intf_in_node(node, intf)

          warn "Error: intf:#{node}[#{intf}] is not found in #{grp_key}"
          found_error = true
          next
        end
      end
      exit 1 if found_error
    end
    # rubocop:enable Metrics/MethodLength
  end
end
