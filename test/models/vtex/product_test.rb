require 'test_helper'

module Vtex
  class ProductTest < ActiveSupport::TestCase
    test 'pending_enrichment returns only products without a creation_date' do
      pending = Vtex::Product.create!(sku_code: 'SKU-P', identifier: 'REF-P')
      enriched = Vtex::Product.create!(sku_code: 'SKU-E', identifier: 'REF-E', creation_date: Time.current)

      assert_includes Vtex::Product.pending_enrichment, pending
      assert_not_includes Vtex::Product.pending_enrichment, enriched
    end
  end
end
