require 'test_helper'
require 'minitest/mock'

module Vtex
  module Api
    class ClientTest < ActiveSupport::TestCase
      class FakeResponse
        def initialize(code:, headers: {}, body: '{}')
          @code = code
          @headers = headers
          @body = body
        end

        def status
          HTTP::Response::Status.new(@code)
        end

        attr_reader :headers, :body

        def uri
          'https://example.com'
        end

        def parse
          JSON.parse(@body)
        end
      end

      class FakeHttp
        attr_reader :requests, :path

        def initialize(response)
          @response = response
          @requests = 0
        end

        def get(path = nil, *)
          @requests += 1
          @path = path
          @response
        end
      end

      setup do
        @client = Vtex::Api::Client.new(account_name: 'acc', environment: 'env',
                                        app_token: 'token', app_key: 'key')
      end

      test 'raises RateLimitError honoring the Retry-After header on 429' do
        respond_with(FakeResponse.new(code: 429, headers: { 'Retry-After' => '45' }))

        error = assert_raises(Vtex::Api::RateLimitError) { @client.get_order('123') }

        assert_equal 45, error.retry_after
      end

      test 'falls back to the default Retry-After when the header is missing on 429' do
        respond_with(FakeResponse.new(code: 429))

        error = assert_raises(Vtex::Api::RateLimitError) { @client.get_order('123') }

        assert_equal Vtex::Api::Client::DEFAULT_RETRY_AFTER, error.retry_after
      end

      test 'raises the generic request error for other non-ok statuses' do
        respond_with(FakeResponse.new(code: 500))

        assert_raises(HTTP::RequestError) { @client.get_order('123') }
      end

      test 'treats a 503 throttling response as a rate limit and records a cooldown' do
        respond_with(FakeResponse.new(
                       code: 503,
                       headers: { 'Content-Type' => 'application/vnd.vtex.throttling.v1+json; charset=utf-8' },
                       body: '{"throttlingResult":"MaxConcurrentRequestsByInstance"}'
                     ))

        error = assert_raises(Vtex::Api::RateLimitError) { @client.get_order('123') }

        assert_equal Vtex::Api::Client::DEFAULT_RETRY_AFTER, error.retry_after
        assert ApiCooldown.cooling_down?(Vtex::Api::Client::COOLDOWN_KEY)
      end

      test 'does not treat a plain 503 without the throttling content-type as a rate limit' do
        respond_with(FakeResponse.new(code: 503, headers: { 'Content-Type' => 'text/html' }))

        assert_raises(HTTP::RequestError) { @client.get_order('123') }
        assert_not ApiCooldown.cooling_down?(Vtex::Api::Client::COOLDOWN_KEY)
      end

      test 'parses the body on a successful response' do
        respond_with(FakeResponse.new(code: 200, body: '{"orderId":"123"}'))

        assert_equal({ 'orderId' => '123' }, @client.get_order('123'))
      end

      test 'requests the catalog SKU endpoint and parses the body' do
        http = respond_with(FakeResponse.new(code: 200, body: '{"Id":1,"IsKit":true,"IsActive":false}'))

        result = @client.get_sku('123-01')

        assert_equal '/api/catalog/pvt/stockkeepingunit/123-01', http.path
        assert_equal({ 'Id' => 1, 'IsKit' => true, 'IsActive' => false }, result)
      end

      test 'short-circuits get_sku without touching the API while a cooldown is active' do
        ApiCooldown.cool_down!(Vtex::Api::Client::COOLDOWN_KEY, 40)
        http = respond_with(FakeResponse.new(code: 200, body: '{"Id":1}'))

        error = assert_raises(Vtex::Api::RateLimitError) { @client.get_sku('123-01') }

        assert_equal 40, error.retry_after
        assert_equal 0, http.requests
      end

      test 'records a shared cooldown when the VTEX API rate limits us' do
        respond_with(FakeResponse.new(code: 429, headers: { 'Retry-After' => '50' }))

        assert_raises(Vtex::Api::RateLimitError) { @client.get_order('123') }

        assert ApiCooldown.cooling_down?(Vtex::Api::Client::COOLDOWN_KEY)
        assert_equal 50, ApiCooldown.retry_after_seconds(Vtex::Api::Client::COOLDOWN_KEY)
      end

      test 'short-circuits without touching the API while a cooldown is active' do
        ApiCooldown.cool_down!(Vtex::Api::Client::COOLDOWN_KEY, 40)
        http = respond_with(FakeResponse.new(code: 200, body: '{"orderId":"123"}'))

        error = assert_raises(Vtex::Api::RateLimitError) { @client.get_order('123') }

        assert_equal 40, error.retry_after
        assert_equal 0, http.requests
      end

      private

      def respond_with(response)
        http = FakeHttp.new(response)
        @client.define_singleton_method(:http) { http }
        http
      end
    end
  end
end
