module Vtex
  module Api
    class Client
      def initialize(account_name:, environment:, app_token:, app_key:)
        @account_name = account_name
        @environment = environment
        @app_token = app_token
        @app_key = app_key
      end

      # https://developers.vtex.com/reference/orders#getorder
      def get_order(order_id)
        http.get("/api/oms/pvt/orders/#{order_id}")
      end

      def list_orders(creation_date_range:, params: {})
        creation_date_begin = creation_date_range.begin.as_json
        creation_date_end = creation_date_range.end.as_json
        params[:f_creationDate] = "creationDate:[#{creation_date_begin} TO #{creation_date_end}]"
        http.get('/api/oms/pvt/orders', params: params)
      end

      private

      def http
        @http ||= create_http
      end

      def create_http
        HTTP['X-VTEX-API-AppToken': @app_token, 'X-VTEX-API-AppKey': @app_key].persistent vtex_api_base_url
      end

      def vtex_api_base_url
        "https://#{@account_name}.#{@environment}.com.br"
      end
    end
  end
end
