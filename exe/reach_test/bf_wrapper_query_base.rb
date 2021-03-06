# frozen_string_literal: true

require 'httpclient'
require 'json'

module TopologyOperator
  # Batfish-Wrapper Query base: base class to query batfish via batfish-wrapper
  class BFWrapperQueryBase
    def initialize
      @client = HTTPClient.new
    end

    protected

    # @param [String] api API string
    # @param [Hash] param GET parameter
    # @return [Object,nil] JSON parsed object
    def bfw_query(api, param = {})
      batfish_wrapper = ENV['BATFISH_WRAPPER_HOST'] || 'localhost:5000'
      url = "http://#{[batfish_wrapper, api].join('/').gsub(%r{/+}, '/')}"

      # # debug
      # param_str = param.each_key.map { |k| "#{k}=#{param[k]}" }.join('&')
      # warn "# url = #{param.empty? ? url : [url, param_str].join('?')}"

      res = param.empty? ? @client.get(url) : @client.get(url, query: param)
      res.status == 200 ? JSON.parse(res.body) : nil
    end

    # @return [String,nil] json string
    def fetch_interface_list
      # - node: str
      #   interface: str
      #   addresses: []
      # - ...
      bfw_query("/api/networks/#{@env_table['network']}/snapshots/#{@env_table['snapshot']}/interfaces")
    end

    # @param [String] network Network name in batfish
    # @param [String] snapshot Snapshot name in network
    # @param [String] src_node Source-node name
    # @param [String] src_intf Source-interface name
    # @param [String] dst_ip Destination IP address
    # @return [Hash,nil]
    def fetch_traceroute(network, snapshot, src_node, src_intf, dst_ip)
      url = "/api/networks/#{network}/snapshots/#{snapshot}/nodes/#{src_node}/traceroute"
      param = { 'interface' => src_intf, 'destination' => dst_ip }
      # network: str
      # snapshot: str
      # snapshot_info:
      #   description: str
      #   index: int
      #   lost_edges: []
      #   original_snapshot_path: str
      #   snapshot_path: str
      # result:
      #   - Flow: {}
      #     Traces: []
      #   - ...
      bfw_query(url, param)
    end

    # @return [Array<String>,nil] networks
    def fetch_networks
      bfw_query('/api/networks')
    end

    # @return [Array<String>,nil] snapshots
    def fetch_snapshots(network)
      bfw_query("/api/networks/#{network}/snapshots")
    end
  end
end
