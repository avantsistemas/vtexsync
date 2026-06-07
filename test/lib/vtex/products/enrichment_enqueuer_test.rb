require 'test_helper'

module Vtex
  module Products
    class EnrichmentEnqueuerTest < ActiveSupport::TestCase
      include ActiveJob::TestHelper

      setup do
        @pending_a = create_product('SKU-A')
        @pending_b = create_product('SKU-B')
        @enriched = create_product('SKU-C', creation_date: Time.current)

        # Os produtos acima enfileiram seu próprio enriquecimento via
        # after_create_commit; descartamos para medir só o que o enqueuer faz.
        clear_enqueued_jobs
      end

      test 'enqueues an enrichment job for each pending product' do
        result = nil
        assert_enqueued_jobs 2, only: Vtex::Sync::ProductEnrichmentJob do
          result = Vtex::Products::EnrichmentEnqueuer.call
        end

        assert_equal({ total: 2, enqueued: 2 }, result)

        enqueued_ids = enqueued_jobs.map { |job| job[:args].first }

        assert_includes enqueued_ids, @pending_a.id
        assert_includes enqueued_ids, @pending_b.id
        assert_not_includes enqueued_ids, @enriched.id
      end

      test 'reprocesses the whole catalog when all: true' do
        result = nil
        assert_enqueued_jobs 3, only: Vtex::Sync::ProductEnrichmentJob do
          result = Vtex::Products::EnrichmentEnqueuer.call(all: true)
        end

        assert_equal({ total: 3, enqueued: 3 }, result)
      end

      test 'enqueues enrichment jobs with the lowest priority' do
        Vtex::Products::EnrichmentEnqueuer.call

        assert_predicate enqueued_jobs, :any?, 'esperava ao menos um job enfileirado'
        assert(enqueued_jobs.all? { |job| job[:priority] == JobPriority::LOWEST })
      end

      test 'staggers jobs into waves spaced by the batch interval' do
        freeze_time do
          Vtex::Products::EnrichmentEnqueuer.call(batch_size: 1, batch_interval: 30.seconds)

          relative_waits = enqueued_jobs.map { |job| (job[:at] - Time.current.to_f).round }

          assert_equal [0, 30], relative_waits.sort
        end
      end

      test 'offsets every wave by the active cooldown known at enqueue time' do
        freeze_time do
          ApiCooldown.cool_down!(Vtex::Api::Client::COOLDOWN_KEY, 40)
          Vtex::Products::EnrichmentEnqueuer.call(batch_size: 1, batch_interval: 30.seconds)

          relative_waits = enqueued_jobs.map { |job| (job[:at] - Time.current.to_f).round }

          # 1ª onda adiada para o fim do cooldown (40s); 2ª onda 30s depois.
          assert_equal [40, 70], relative_waits.sort
        end
      end

      test 'respects the limit parameter' do
        result = nil
        assert_enqueued_jobs 1, only: Vtex::Sync::ProductEnrichmentJob do
          result = Vtex::Products::EnrichmentEnqueuer.call(limit: 1)
        end

        assert_equal({ total: 1, enqueued: 1 }, result)
      end

      test 'rejects a non-positive batch size before enqueuing anything' do
        assert_no_enqueued_jobs do
          assert_raises(ArgumentError) { Vtex::Products::EnrichmentEnqueuer.call(batch_size: 0) }
        end
      end

      test 'rejects a non-positive batch interval before enqueuing anything' do
        assert_no_enqueued_jobs do
          assert_raises(ArgumentError) { Vtex::Products::EnrichmentEnqueuer.call(batch_interval: 0.seconds) }
        end
      end

      private

      def create_product(sku_code, **attributes)
        Vtex::Product.create!(sku_code: sku_code, identifier: "REF-#{sku_code}", **attributes)
      end
    end
  end
end
