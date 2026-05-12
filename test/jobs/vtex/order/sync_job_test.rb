require 'test_helper'
require 'minitest/mock'

module Vtex
  class Order
    class SyncJobTest < ActiveJob::TestCase
      class FakeApiClient
        attr_reader :requested_order_ids

        def initialize(payload)
          @payload = payload
          @requested_order_ids = []
        end

        def get_order(order_id)
          requested_order_ids << order_id
          @payload
        end
      end

      setup do
        @payload = JSON.parse(Rails.root.join('test/fixtures/files/get_order_bioextratus.json').read)
        Vtex::Sync::Order.new(FakeApiClient.new(@payload)).sync(@payload.fetch('orderId'))
        @order = Vtex::Order.find_by!(order_code: @payload.fetch('orderId'))
        @credentials_stub = { app_token: 'test-token', app_key: 'test-key' }
      end

      test 'is configured with the expected queue and priority' do
        job = Vtex::Order::SyncJob.new(@order.order_code)

        assert_equal 'vtex_order_sync', job.queue_name
        assert_equal JobPriority::HIGHEST, job.priority
      end

      test 'builds the api client using the configured account, environment and credentials' do
        client_arguments = nil
        build_client = lambda do |**arguments|
          client_arguments = arguments
          FakeApiClient.new(@payload)
        end

        Rails.application.credentials.stub(:vtex, @credentials_stub) do
          Vtex::Api::Client.stub(:new, build_client) do
            Vtex::Order::SyncJob.perform_now(@order.order_code)
          end
        end

        assert_equal 'bioextratusvirtual', client_arguments.fetch(:account_name)
        assert_equal 'vtexcommercestable', client_arguments.fetch(:environment)
        assert_equal 'test-token', client_arguments.fetch(:app_token)
        assert_equal 'test-key', client_arguments.fetch(:app_key)
      end

      test 'requests the order matching the given order_id from the api' do
        api_client = FakeApiClient.new(@payload)

        Rails.application.credentials.stub(:vtex, @credentials_stub) do
          Vtex::Api::Client.stub(:new, ->(**_args) { api_client }) do
            Vtex::Order::SyncJob.perform_now(@order.order_code)
          end
        end

        assert_equal [@order.order_code], api_client.requested_order_ids
      end

      test 'persists changes returned by the api into the order graph' do
        updated_payload = @payload.deep_dup
        updated_payload['status'] = 'payment-approved'
        updated_payload['statusDescription'] = 'Pagamento aprovado'

        Rails.application.credentials.stub(:vtex, @credentials_stub) do
          Vtex::Api::Client.stub(:new, ->(**_args) { FakeApiClient.new(updated_payload) }) do
            Vtex::Order::SyncJob.perform_now(@order.order_code)
          end
        end

        @order.reload

        assert_equal 'payment-approved', @order.status
        assert_equal 'Pagamento aprovado', @order.status_description
      end

      test 'clears resync flag after a successful sync' do
        @order.update_columns(resync_requested_at: 1.hour.ago, resync_reason: 'estrutura X adicionada')

        run_job

        @order.reload

        assert_nil @order.resync_requested_at
        assert_nil @order.resync_reason
      end

      test 'leaves the order untouched when no resync flag was set' do
        original_updated_at = @order.updated_at

        run_job

        @order.reload

        assert_nil @order.resync_requested_at
        assert_nil @order.resync_reason
        assert_equal original_updated_at, @order.updated_at
      end

      private

      def run_job
        Rails.application.credentials.stub(:vtex, @credentials_stub) do
          Vtex::Api::Client.stub(:new, ->(**_args) { FakeApiClient.new(@payload) }) do
            Vtex::Order::SyncJob.perform_now(@order.order_code)
          end
        end
      end
    end
  end
end
