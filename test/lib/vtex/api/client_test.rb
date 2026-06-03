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
        def initialize(response)
          @response = response
        end

        def get(*)
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

      test 'parses the body on a successful response' do
        respond_with(FakeResponse.new(code: 200, body: '{"orderId":"123"}'))

        assert_equal({ 'orderId' => '123' }, @client.get_order('123'))
      end

      private

      def respond_with(response)
        @client.define_singleton_method(:http) { FakeHttp.new(response) }
      end
    end
  end
end
