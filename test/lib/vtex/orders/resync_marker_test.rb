require 'test_helper'

module Vtex
  module Orders
    class ResyncMarkerTest < ActiveSupport::TestCase
      setup { seed_orders }

      test 'opens a pending request only for the orders listed in order_codes' do
        now = Time.zone.local(2026, 5, 12, 10, 0, 0)
        affected = travel_to(now) do
          Vtex::Orders::ResyncMarker.call(
            order_codes: [@order_no_channel.order_code, @order_recent.order_code],
            reason: 'estrutura X adicionada'
          )
        end

        assert_equal 2, affected
        assert pending_request_for?(@order_no_channel)
        assert pending_request_for?(@order_recent)
        assert_not pending_request_for?(@order_with_channel)

        request = @order_no_channel.resync_requests.sole

        assert_equal now, request.requested_at
        assert_equal 'estrutura X adicionada', request.reason
        assert_nil request.completed_at
      end

      test 'opens requests for orders matching the given scope clause' do
        Vtex::Orders::ResyncMarker.call(scope: 'sales_channel IS NULL')

        assert pending_request_for?(@order_no_channel)
        assert_not pending_request_for?(@order_with_channel)
      end

      test 'opens requests for orders inside the given date range' do
        Vtex::Orders::ResyncMarker.call(
          from: Time.zone.parse('2025-01-01'),
          to: Time.zone.parse('2025-12-31')
        )

        assert pending_request_for?(@order_no_channel)
        assert pending_request_for?(@order_with_channel)
        assert_not pending_request_for?(@order_recent)
      end

      test 'refreshes the open request instead of stacking another for the same order' do
        travel_to(Time.zone.local(2026, 5, 12, 9, 0, 0)) do
          Vtex::Orders::ResyncMarker.call(order_codes: [@order_no_channel.order_code], reason: 'primeira')
        end

        refreshed_at = Time.zone.local(2026, 5, 12, 10, 0, 0)
        assert_no_difference -> { Vtex::OrderResyncRequest.count } do
          travel_to(refreshed_at) do
            Vtex::Orders::ResyncMarker.call(order_codes: [@order_no_channel.order_code], reason: 'segunda')
          end
        end

        request = @order_no_channel.resync_requests.sole

        assert_equal 'segunda', request.reason
        assert_equal refreshed_at, request.requested_at
      end

      test 'raises when no filter is provided' do
        assert_raises(ArgumentError) { Vtex::Orders::ResyncMarker.call }
        assert_equal 0, Vtex::OrderResyncRequest.count
      end

      private

      def pending_request_for?(order)
        order.resync_requests.pending.exists?
      end

      class FakeApiClient
        def initialize(payload)
          @payload = payload
        end

        def get_order(_order_id)
          @payload
        end
      end

      def seed_orders
        payload = JSON.parse(Rails.root.join('test/fixtures/files/get_order_bioextratus.json').read)
        Vtex::Sync::Order.new(FakeApiClient.new(payload)).call(payload.fetch('orderId'))
        base = Vtex::Order.find_by!(order_code: payload.fetch('orderId'))

        @order_no_channel = build_sibling_order(base, order_code: 'RESYNC-A', sales_channel: nil,
                                                      creation_date: Time.zone.local(2025, 3, 15))
        @order_with_channel = build_sibling_order(base, order_code: 'RESYNC-B', sales_channel: '1',
                                                        creation_date: Time.zone.local(2025, 8, 1))
        @order_recent = build_sibling_order(base, order_code: 'RESYNC-C', sales_channel: nil,
                                                  creation_date: Time.zone.local(2026, 4, 1))
      end

      def build_sibling_order(base, **attributes)
        Vtex::Order.create!(client: base.client, address: base.address, **attributes)
      end
    end
  end
end
