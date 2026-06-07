require 'test_helper'
require 'minitest/mock'

module Vtex
  module Sync
    class ProductEnrichmentJobTest < ActiveJob::TestCase
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
        # Descarta o job de enriquecimento enfileirado pelo after_create_commit
        # acima, para não interferir nas asserções de fila.
        clear_enqueued_jobs
        @payload = { 'IsKit' => true, 'IsActive' => false, 'CreationDate' => '2022-06-15T10:00:00' }
        @credentials_stub = { app_token: 'test-token', app_key: 'test-key' }
      end

      test 'is configured with the expected queue and priority' do
        job = Vtex::Sync::ProductEnrichmentJob.new(@product.id)

        assert_equal 'vtex_sync_product_enrichment', job.queue_name
        assert_equal JobPriority::LOWER, job.priority
      end

      test 'enriches the product matching the given id' do
        perform_with(FakeApiClient.new(@payload))

        @product.reload

        assert @product.kit
        assert_not @product.active
        assert_not_nil @product.creation_date
      end

      test 'does nothing when the product no longer exists' do
        built = false

        Vtex::Api::Client.stub(:new, lambda { |**_args|
          built = true
          FakeApiClient.new(@payload)
        }) do
          Vtex::Sync::ProductEnrichmentJob.perform_now(-1)
        end

        assert_not built, 'não deveria construir o client para um produto inexistente'
      end

      test 'reschedules itself when the VTEX API rate limits the request' do
        assert_enqueued_with(job: Vtex::Sync::ProductEnrichmentJob, args: [@product.id]) do
          perform_with_rate_limited_client(Vtex::Sync::ProductEnrichmentJob.new(@product.id))
        end
      end

      test 'gives up and notifies Honeybadger once rate limit retries are exhausted' do
        job = Vtex::Sync::ProductEnrichmentJob.new(@product.id)
        job.executions = Vtex::Sync::ProductEnrichmentJob::MAX_RATE_LIMIT_ATTEMPTS - 1

        notified = nil
        notify = ->(error, **_opts) { notified = error }

        assert_no_enqueued_jobs do
          Honeybadger.stub(:notify, notify) do
            perform_with_rate_limited_client(job)
          end
        end

        assert_instance_of Vtex::Api::RateLimitError, notified
      end

      private

      def perform_with(client)
        Rails.application.credentials.stub(:vtex, @credentials_stub) do
          Vtex::Api::Client.stub(:new, ->(**_args) { client }) do
            Vtex::Sync::ProductEnrichmentJob.perform_now(@product.id)
          end
        end
      end

      def perform_with_rate_limited_client(job)
        rate_limited_client = Object.new
        def rate_limited_client.get_sku(_sku_id)
          raise Vtex::Api::RateLimitError.new(retry_after: 30)
        end

        Rails.application.credentials.stub(:vtex, @credentials_stub) do
          Vtex::Api::Client.stub(:new, ->(**_args) { rate_limited_client }) do
            job.perform_now
          end
        end
      end
    end
  end
end
