module Vtex
  module Api
    class Client
      def initialize(account_name:, environment:, app_token:, app_key:)
        @account_name = account_name
        @environment = environment
        @app_token = app_token
        @app_key = app_key
      end

      # https://developers.vtex.com/vtex-developer-docs/reference/orders#getorder
      def get_order(order_id)
        parse_response http.get("/api/oms/pvt/orders/#{order_id}")
      end

      # https://developers.vtex.com/vtex-developer-docs/reference/orders#listorders
      def list_orders(creation_date_range:, params: {})
        creation_date_begin = creation_date_range.begin.utc.as_json
        creation_date_end = creation_date_range.end.utc.as_json
        params[:f_creationDate] = "creationDate:[#{creation_date_begin} TO #{creation_date_end}]"
        parse_response http.get('/api/oms/pvt/orders', params: params)
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

      def parse_response(response)
        raise_http_request_error(response) unless response.status.ok?
        log_response(response)
        response.parse
      end

      def log_response(response)
        Rails.logger.debug { "#{response.uri} => #{response.status} #{response.body}" }
      end

      def raise_http_request_error(response)
        raise HTTP::RequestError, "#{response.uri} => #{response.status} #{response.body} (#{response.headers.to_h})"
      end
    end

    class Pagination
      def initialize(http, path, params)
        @http = http
        @path = path
        @params = params
      end
    end
  end
end
