require 'test_helper'

module Vtex
  module Orders
    class ResyncEnqueuerTest < ActiveSupport::TestCase
      include ActiveJob::TestHelper

      setup { seed_orders }

      test 'enqueues a sync job for each pending order' do
        @order_no_channel.update_columns(resync_requested_at: 1.hour.ago)
        @order_recent.update_columns(resync_requested_at: 30.minutes.ago)

        result = nil
        assert_enqueued_jobs 2, only: Vtex::Order::SyncJob do
          result = Vtex::Orders::ResyncEnqueuer.call
        end

        assert_equal({ total: 2, enqueued: 2 }, result)

        enqueued_order_codes = enqueued_jobs.map { |job| job[:args].first }

        assert_includes enqueued_order_codes, @order_no_channel.order_code
        assert_includes enqueued_order_codes, @order_recent.order_code
        assert_not_includes enqueued_order_codes, @order_with_channel.order_code
      end

      test 'respects the limit parameter' do
        @order_no_channel.update_columns(resync_requested_at: 1.hour.ago)
        @order_recent.update_columns(resync_requested_at: 30.minutes.ago)

        result = nil
        assert_enqueued_jobs 1, only: Vtex::Order::SyncJob do
          result = Vtex::Orders::ResyncEnqueuer.call(limit: 1)
        end

        assert_equal({ total: 1, enqueued: 1 }, result)
      end

      private

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
        Vtex::Sync::Order.new(FakeApiClient.new(payload)).sync(payload.fetch('orderId'))
        base = Vtex::Order.find_by!(order_code: payload.fetch('orderId'))

        @order_no_channel = build_sibling_order(base, order_code: 'RESYNC-A')
        @order_with_channel = build_sibling_order(base, order_code: 'RESYNC-B')
        @order_recent = build_sibling_order(base, order_code: 'RESYNC-C')
      end

      def build_sibling_order(base, **attributes)
        Vtex::Order.create!(client: base.client, address: base.address, **attributes)
      end
    end
  end
end
