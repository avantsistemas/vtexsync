require 'test_helper'

module Vtex
  module Sync
    class ProductEnrichmentTest < ActiveSupport::TestCase
      class FakeApiClient
        attr_reader :requested_sku_ids

        def initialize(payload)
          @payload = payload
          @requested_sku_ids = []
        end

        def get_sku(sku_id)
          requested_sku_ids << sku_id
          @payload
        end
      end

      setup do
        @product = Vtex::Product.create!(sku_code: 'SKU-1', identifier: 'REF-1')
        @payload = { 'IsKit' => true, 'IsActive' => false, 'CreationDate' => '2022-06-15T10:00:00' }
      end

      test 'updates the product with catalog attributes fetched by SKU' do
        Vtex::Sync::ProductEnrichment.new(FakeApiClient.new(@payload)).call(@product)

        @product.reload

        assert @product.kit
        assert_not @product.active
        assert_equal Date.new(2022, 6, 15), @product.creation_date.to_date
      end

      test 'requests the SKU matching the product sku_code' do
        client = FakeApiClient.new(@payload)

        Vtex::Sync::ProductEnrichment.new(client).call(@product)

        assert_equal ['SKU-1'], client.requested_sku_ids
      end

      test 'returns the enriched product' do
        result = Vtex::Sync::ProductEnrichment.new(FakeApiClient.new(@payload)).call(@product)

        assert_equal @product, result
      end
    end
  end
end
