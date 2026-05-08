require 'test_helper'
require 'rake'
require 'minitest/mock'

module Vtex
  class SyncRakeTest < ActiveSupport::TestCase
    setup do
      Rails.application.load_tasks if Rake::Task.tasks.none? { |task| task.name == 'vtex:sync_order' }
      Rake::Task['vtex:sync_order'].reenable
    end

    teardown do
      ENV.delete('order_id')
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
  end
end
