require 'test_helper'

module Vtex
  class ProductTest < ActiveJob::TestCase
    test 'enqueues catalog enrichment after a new product is created' do
      assert_enqueued_with(job: Vtex::Sync::ProductEnrichmentJob) do
        Vtex::Product.create!(sku_code: 'SKU-NEW', identifier: 'REF-NEW')
      end
    end

    test 'does not re-enqueue enrichment when an existing product is updated' do
      product = Vtex::Product.create!(sku_code: 'SKU-UPD', identifier: 'REF-UPD')
      clear_enqueued_jobs

      assert_no_enqueued_jobs do
        product.update!(name: 'Novo nome')
      end
    end

    test 'pending_enrichment returns only products without a creation_date' do
      pending = Vtex::Product.create!(sku_code: 'SKU-P', identifier: 'REF-P')
      enriched = Vtex::Product.create!(sku_code: 'SKU-E', identifier: 'REF-E', creation_date: Time.current)

      assert_includes Vtex::Product.pending_enrichment, pending
      assert_not_includes Vtex::Product.pending_enrichment, enriched
    end
  end
end
