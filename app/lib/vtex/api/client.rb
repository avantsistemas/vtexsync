module Vtex
  module Api
    class Client
      # Espera padrão quando a VTEX responde 429 sem um Retry-After válido.
      # A própria documentação recomenda ~1 minuto de backoff.
      DEFAULT_RETRY_AFTER = 60

      # Monta um cliente a partir da conta/credenciais configuradas.
      def self.build
        new(account_name: Rails.configuration.application.vtex[:account_name],
            environment: Rails.configuration.application.vtex[:environment],
            app_token: Rails.application.credentials.vtex[:app_token],
            app_key: Rails.application.credentials.vtex[:app_key])
      end

      def initialize(account_name:, environment:, app_token:, app_key:)
        @account_name = account_name
        @environment = environment
        @app_token = app_token
        @app_key = app_key
      end

      # https://developers.vtex.com/docs/api-reference/orders-api#get-/api/oms/pvt/orders/-orderId-
      def get_order(order_id)
        parse_response http.get("/api/oms/pvt/orders/#{order_id}")
      end

      # https://developers.vtex.com/docs/api-reference/orders-api#get-/api/oms/pvt/orders
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
        raise_rate_limit_error(response) if response.status.too_many_requests?
        raise_http_request_error(response) unless response.status.ok?
        log_response(response)
        response.parse
      end

      def log_response(response)
        Rails.logger.debug { "#{response.uri} => #{response.status} #{response.body}" }
      end

      def raise_rate_limit_error(response)
        retry_after = response.headers['Retry-After'].to_i
        retry_after = DEFAULT_RETRY_AFTER unless retry_after.positive?
        raise RateLimitError.new(retry_after: retry_after)
      end

      def raise_http_request_error(response)
        raise HTTP::RequestError, "#{response.uri} => #{response.status} #{response.body} (#{response.headers.to_h})"
      end
    end
  end
end
