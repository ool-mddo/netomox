# frozen_string_literal: true

module Netomox
  module Topology
    # Diff state container
    class DiffState
      attr_accessor :forward, :backward, :pair, :diff_data

      # Restore diff state from RFC8345-based data with `_diff_state_` (output of #to_data)
      # NOTICE: `pair` is a path string in the data (the counter-part object is not restored).
      # @param [Hash] data Value of `_diff_state_` (keys: forward, backward, pair, diff_data)
      # @return [DiffState]
      def self.from_data(data)
        new(
          forward: data['forward']&.intern,
          backward: data['backward']&.intern,
          pair: data['pair'],
          diff_data: data['diff_data'] || nil
        )
      end

      # @param [Symbol] forward Diff state in forward-check
      # @param [Symbol] backward Diff state in backward-check
      # @param [TopoObjectBase] pair Counter-part object to compare
      def initialize(forward: :kept, backward: nil, pair: nil, diff_data: nil)
        @forward = forward
        @backward = backward
        @pair = pair
        @diff_data = diff_data
      end

      # @return [Symbol] Diff state (:added, :deleted, :kept, :changed)
      def detect
        if %i[added deleted].include?(@forward)
          # add/delete are used only in forward check
          @forward
        elsif [@forward, @backward].include?(:changed)
          :changed
        else
          # when [fwd,bwd] => [:kept, nil] or [:kept, :kept]
          :kept
        end
      end

      # @return [String]
      def to_s
        name = @pair && !@pair.empty? ? pair_label(:name) : ''
        "diff_state: fwd:#{@forward}, bwd:#{@backward}, pair:#{name}"
      end

      # Convert to data for RFC8345 format
      # @return [Hash]
      def to_data
        data = {
          forward: @forward,
          backward: @backward,
          pair: @pair.nil? || @pair.empty? ? '' : pair_label(:path)
        }
        # diff_data is optional
        data[:diff_data] = @diff_data unless @diff_data.nil? || @diff_data.empty?
        data
      end

      def kept?
        detect == :kept
      end

      # @return [Boolean]
      def empty?
        !(@forward || @backward || @pair)
      end

      private

      # `pair` is the counter-part object when the state is made by diff, or a path string when it is
      # restored from data (see .from_data).
      # @param [Symbol] method Method to get the label from the counter-part object (:name or :path)
      # @return [String]
      def pair_label(method)
        @pair.is_a?(String) ? @pair : @pair.send(method)
      end
    end
  end
end
