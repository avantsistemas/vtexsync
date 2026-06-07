require 'test_helper'

module Vtex
  module Orders
    class ResyncEnqueuerTest < ActiveSupport::TestCase
      include ActiveJob::TestHelper

      setup { seed_orders }

      test 'enqueues a sync job for each pending order' do
        request_resync(@order_no_channel)
        request_resync(@order_recent)

        result = nil
        assert_enqueued_jobs 2, only: Vtex::Sync::OrderJob do
          result = Vtex::Orders::ResyncEnqueuer.call
        end

        assert_equal({ total: 2, enqueued: 2 }, result)

        enqueued_order_codes = enqueued_jobs.map { |job| job[:args].first }

        assert_includes enqueued_order_codes, @order_no_channel.order_code
        assert_includes enqueued_order_codes, @order_recent.order_code
        assert_not_includes enqueued_order_codes, @order_with_channel.order_code
      end

      test 'enqueues resync jobs with the lowest priority' do
        request_resync(@order_no_channel)

        Vtex::Orders::ResyncEnqueuer.call

        assert_predicate enqueued_jobs, :any?, 'esperava ao menos um job enfileirado'
        assert(enqueued_jobs.all? { |job| job[:priority] == JobPriority::LOWEST })
      end

      test 'staggers jobs into waves spaced by the batch interval' do
        request_resync(@order_no_channel)
        request_resync(@order_recent)

        freeze_time do
          Vtex::Orders::ResyncEnqueuer.call(batch_size: 1, batch_interval: 30.seconds)

          relative_waits = enqueued_jobs.map { |job| (job[:at] - Time.current.to_f).round }

          assert_equal [0, 30], relative_waits.sort
        end
      end

      test 'enqueues the whole first wave immediately when it fits the batch size' do
        request_resync(@order_no_channel)
        request_resync(@order_recent)

        freeze_time do
          Vtex::Orders::ResyncEnqueuer.call(batch_size: 100, batch_interval: 1.minute)

          relative_waits = enqueued_jobs.map { |job| (job[:at] - Time.current.to_f).round }

          assert_equal [0, 0], relative_waits
        end
      end

      test 'offsets every wave by the active cooldown known at enqueue time' do
        request_resync(@order_no_channel)
        request_resync(@order_recent)

        freeze_time do
          ApiCooldown.cool_down!(Vtex::Api::Client::COOLDOWN_KEY, 40)
          Vtex::Orders::ResyncEnqueuer.call(batch_size: 1, batch_interval: 30.seconds)

          relative_waits = enqueued_jobs.map { |job| (job[:at] - Time.current.to_f).round }

          # 1ª onda adiada para o fim do cooldown (40s); 2ª onda 30s depois.
          assert_equal [40, 70], relative_waits.sort
        end
      end

      test 'rejects a non-positive batch size before enqueuing anything' do
        request_resync(@order_no_channel)

        assert_no_enqueued_jobs do
          assert_raises(ArgumentError) { Vtex::Orders::ResyncEnqueuer.call(batch_size: 0) }
        end
      end

      test 'rejects a non-positive batch interval before enqueuing anything' do
        request_resync(@order_no_channel)

        assert_no_enqueued_jobs do
          assert_raises(ArgumentError) { Vtex::Orders::ResyncEnqueuer.call(batch_interval: 0.seconds) }
        end
      end

      test 'respects the limit parameter' do
        request_resync(@order_no_channel)
        request_resync(@order_recent)

        result = nil
        assert_enqueued_jobs 1, only: Vtex::Sync::OrderJob do
          result = Vtex::Orders::ResyncEnqueuer.call(limit: 1)
        end

        assert_equal({ total: 1, enqueued: 1 }, result)
      end

      private

      def request_resync(order)
        order.resync_requests.create!(requested_at: Time.current)
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
