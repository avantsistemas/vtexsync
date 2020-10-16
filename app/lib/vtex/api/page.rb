module Vtex
  module Api
    class Page
      def self.paginate(api_client:, client_method:, method_args:)
        new(api_client: api_client,
            client_method: client_method,
            method_args: method_args)
      end

      def next?
        !client_method_called? || there_are_more_pages?
      end

      def next
        return nil unless next?

        next_page if client_method_called?

        @result = call_client_method
      end

      private

      def initialize(api_client:, client_method:, method_args:)
        @api_client = api_client
        @client_method = client_method
        @method_args = method_args
      end

      def next_page
        params = @method_args[:params] ||= {}
        params[:page] = @result['paging']['currentPage'] + 1
      end

      def call_client_method
        @api_client.public_send(@client_method, @method_args).tap { @client_method_called = true }
      end

      def client_method_called?
        @client_method_called.present?
      end

      def there_are_more_pages?
        @result['paging']['currentPage'] < @result['paging']['pages']
      end
    end
  end
end
