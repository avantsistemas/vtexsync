require 'test_helper'
require 'rake'

module Vtex
  class SyncRakeTest < ActiveSupport::TestCase
    setup do
      Rails.application.load_tasks if Rake::Task.tasks.none? { |task| task.name == 'vtex:sync_order' }
      Rake::Task['vtex:sync_order'].reenable
    end

    test 'sync_order rake task syncs requested order without performing the api call itself' do
      order_id = '1069613093223-01'
      api_client = Object.new
      synced_order_ids = []
      sync_order = Object.new
      sync_order.define_singleton_method(:sync) { |requested_order_id| synced_order_ids << requested_order_id }

      client_arguments = nil
      test_case = self
      stub_singleton_method(Rails.application.credentials, :vtex) do
        { app_token: 'test-token', app_key: 'test-key' }
      end
      stub_singleton_method(Vtex::Api::Client, :new) do |**arguments|
        client_arguments = arguments
        api_client
      end
      stub_singleton_method(Vtex::Sync::Order, :new) do |received_api_client|
        test_case.assert_same api_client, received_api_client
        sync_order
      end

      with_env('order_id' => order_id) do
        Rake::Task['vtex:sync_order'].invoke
      end

      assert_equal [order_id], synced_order_ids
      assert_equal 'bioextratusvirtual', client_arguments.fetch(:account_name)
      assert_equal 'vtexcommercestable', client_arguments.fetch(:environment)
      assert_equal 'test-token', client_arguments.fetch(:app_token)
      assert_equal 'test-key', client_arguments.fetch(:app_key)
    ensure
      restore_singleton_method(Rails.application.credentials, :vtex)
      restore_singleton_method(Vtex::Api::Client, :new)
      restore_singleton_method(Vtex::Sync::Order, :new)
      ENV.delete('order_id')
    end

    private

    def stub_singleton_method(object, method_name, &block)
      singleton_class = object.singleton_class
      singleton_method_stubs[[object, method_name]] =
        if singleton_class.instance_methods(false).include?(method_name) ||
           singleton_class.private_instance_methods(false).include?(method_name)
          singleton_class.instance_method(method_name)
        end

      singleton_class.define_method(method_name, &block)
    end

    def restore_singleton_method(object, method_name)
      singleton_class = object.singleton_class
      original_method = singleton_method_stubs.delete([object, method_name])

      singleton_class.send(:remove_method, method_name)
      singleton_class.define_method(method_name, original_method) if original_method
    rescue NameError
      nil
    end

    def singleton_method_stubs
      @singleton_method_stubs ||= {}
    end

    def with_env(values)
      previous_values = values.each_with_object({}) do |(key, _value), previous|
        previous[key] = ENV.fetch(key, nil)
      end
      values.each { |key, value| ENV[key] = value }

      yield
    ensure
      previous_values.each do |key, value|
        value.nil? ? ENV.delete(key) : ENV[key] = value
      end
    end
  end
end
