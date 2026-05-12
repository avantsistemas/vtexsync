require 'test_helper'
require 'rake'
require 'minitest/mock'

module Vtex
  class SyncRakeTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    RESYNC_ENV_VARS = %w[order_id order_ids scope from to reason limit].freeze

    setup do
      Rails.application.load_tasks if Rake::Task.tasks.none? { |task| task.name == 'vtex:sync_order' }
      %w[vtex:sync_order vtex:mark_for_resync vtex:process_resync_queue].each do |name|
        Rake::Task[name].reenable
      end
    end

    teardown do
      RESYNC_ENV_VARS.each { |key| ENV.delete(key) }
    end

    test 'sync_order rake task syncs requested order without performing the api call itself' do
      order_id = '1069613093223-01'
      api_client = Object.new
      synced_order_ids = []
      sync_order = Object.new
      sync_order.define_singleton_method(:sync) { |requested_order_id| synced_order_ids << requested_order_id }
      client_arguments = nil

      ENV['order_id'] = order_id

      credentials_stub = { app_token: 'test-token', app_key: 'test-key' }
      build_api_client = lambda do |**arguments|
        client_arguments = arguments
        api_client
      end
      build_sync_order = lambda do |received_api_client|
        assert_same api_client, received_api_client
        sync_order
      end

      Rails.application.credentials.stub(:vtex, credentials_stub) do
        Vtex::Api::Client.stub(:new, build_api_client) do
          Vtex::Sync::Order.stub(:new, build_sync_order) do
            Rake::Task['vtex:sync_order'].invoke
          end
        end
      end

      assert_equal [order_id], synced_order_ids
      assert_equal 'bioextratusvirtual', client_arguments.fetch(:account_name)
      assert_equal 'vtexcommercestable', client_arguments.fetch(:environment)
      assert_equal 'test-token', client_arguments.fetch(:app_token)
      assert_equal 'test-key', client_arguments.fetch(:app_key)
    end

    test 'mark_for_resync flags only the orders listed in order_ids' do
      seed_orders
      ENV['order_ids'] = "#{@order_no_channel.order_code}, #{@order_recent.order_code}"
      ENV['reason'] = 'estrutura X adicionada'

      now = Time.zone.local(2026, 5, 12, 10, 0, 0)
      travel_to(now) { Rake::Task['vtex:mark_for_resync'].invoke }

      [@order_no_channel, @order_with_channel, @order_recent].each(&:reload)

      assert_equal now, @order_no_channel.resync_requested_at
      assert_equal now, @order_recent.resync_requested_at
      assert_nil @order_with_channel.resync_requested_at
      assert_equal 'estrutura X adicionada', @order_no_channel.resync_reason
    end

    test 'mark_for_resync flags orders matching the given scope clause' do
      seed_orders
      ENV['scope'] = 'sales_channel IS NULL'

      Rake::Task['vtex:mark_for_resync'].invoke

      assert_predicate @order_no_channel.reload.resync_requested_at, :present?
      assert_nil @order_with_channel.reload.resync_requested_at
    end

    test 'mark_for_resync flags orders inside the given date range' do
      seed_orders
      ENV['from'] = '2025-01-01'
      ENV['to'] = '2025-12-31'

      Rake::Task['vtex:mark_for_resync'].invoke

      assert_predicate @order_no_channel.reload.resync_requested_at, :present?
      assert_predicate @order_with_channel.reload.resync_requested_at, :present?
      assert_nil @order_recent.reload.resync_requested_at
    end

    test 'mark_for_resync raises when no filter is provided' do
      seed_orders

      assert_raises(ArgumentError) { Rake::Task['vtex:mark_for_resync'].invoke }
      assert_equal 0, Vtex::Order.where.not(resync_requested_at: nil).count
    end

    test 'process_resync_queue enqueues a sync job for each pending order' do
      seed_orders
      @order_no_channel.update_columns(resync_requested_at: 1.hour.ago)
      @order_recent.update_columns(resync_requested_at: 30.minutes.ago)

      assert_enqueued_jobs 2, only: Vtex::Order::SyncJob do
        Rake::Task['vtex:process_resync_queue'].invoke
      end

      enqueued_order_codes = enqueued_jobs.map { |job| job[:args].first }

      assert_includes enqueued_order_codes, @order_no_channel.order_code
      assert_includes enqueued_order_codes, @order_recent.order_code
      assert_not_includes enqueued_order_codes, @order_with_channel.order_code
    end

    test 'process_resync_queue respects the limit parameter' do
      seed_orders
      @order_no_channel.update_columns(resync_requested_at: 1.hour.ago)
      @order_recent.update_columns(resync_requested_at: 30.minutes.ago)
      ENV['limit'] = '1'

      assert_enqueued_jobs 1, only: Vtex::Order::SyncJob do
        Rake::Task['vtex:process_resync_queue'].invoke
      end
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
