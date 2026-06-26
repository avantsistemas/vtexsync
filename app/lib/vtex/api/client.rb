module Vtex
  module Api
    class Client
      # Espera padrão quando a VTEX responde 429 sem um Retry-After válido.
      # A própria documentação recomenda ~1 minuto de backoff.
      DEFAULT_RETRY_AFTER = 60

      # Identifica este serviço no portão de cooldown compartilhado (ApiCooldown).
      COOLDOWN_KEY = 'vtex'.freeze

      # Sob carga, a VTEX nem sempre responde 429: quando há requisições
      # concorrentes demais numa instância, ela devolve 503 com um corpo de
      # throttling (ex.: "MaxConcurrentRequestsByInstance"), identificado por
      # este Content-Type. Tratamos isso como rate limit para reaproveitar o
      # cooldown e o reagendamento. Como esse 503 não traz Retry-After, a espera
      # cai no DEFAULT_RETRY_AFTER.
      THROTTLING_CONTENT_TYPE = 'vtex.throttling'.freeze

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
        ensure_not_rate_limited!
        parse_response http.get("/api/oms/pvt/orders/#{order_id}")
      end

      # https://developers.vtex.com/docs/api-reference/catalog-api#get-/api/catalog/pvt/stockkeepingunit/-skuId-
      def get_sku(sku_id)
        ensure_not_rate_limited!
        parse_response http.get("/api/catalog/pvt/stockkeepingunit/#{sku_id}")
      end

      # A marca é atributo do produto e não vem no endpoint de SKU. Este endpoint
      # ("Get SKU and context") expõe BrandId/BrandName (e demais dados de contexto
      # do produto) num único request, com o BrandId no mesmo formato (string) que
      # o pedido usa.
      # https://developers.vtex.com/docs/api-reference/catalog-api#get-/api/catalog_system/pvt/sku/stockkeepingunitbyid/-skuId-
      def get_sku_context(sku_id)
        ensure_not_rate_limited!
        parse_response http.get("/api/catalog_system/pvt/sku/stockkeepingunitbyid/#{sku_id}")
      end

      # https://developers.vtex.com/docs/api-reference/orders-api#get-/api/oms/pvt/orders
      def list_orders(creation_date_range:, params: {})
        ensure_not_rate_limited!
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
        raise_rate_limit_error(response) if rate_limited?(response)
        raise_http_request_error(response) unless response.status.ok?
        log_response(response)
        response.parse
      end

      # A VTEX nos limita de duas formas: o 429 clássico (rate por tempo) e o 503
      # de throttling por concorrência. Ambos pedem o mesmo tratamento de recuo.
      def rate_limited?(response)
        response.status.too_many_requests? || throttled?(response)
      end

      def throttled?(response)
        response.headers['Content-Type'].to_s.include?(THROTTLING_CONTENT_TYPE)
      end

      def log_response(response)
        Rails.logger.debug { "#{response.uri} => #{response.status} #{response.body}" }
      end

      # Se a VTEX já nos limitou recentemente, nem chegamos a tocar na API:
      # levantamos o mesmo erro de rate limit para que o job reagende. Assim,
      # uma rajada de jobs enfileirados ricocheteia barato no portão em vez de
      # cada um arrancar um novo 429 da VTEX.
      def ensure_not_rate_limited!
        return unless ApiCooldown.cooling_down?(COOLDOWN_KEY)

        raise RateLimitError.new(retry_after: ApiCooldown.retry_after_seconds(COOLDOWN_KEY))
      end

      def raise_rate_limit_error(response)
        retry_after = response.headers['Retry-After'].to_i
        retry_after = DEFAULT_RETRY_AFTER unless retry_after.positive?
        ApiCooldown.cool_down!(COOLDOWN_KEY, retry_after)
        raise RateLimitError.new(retry_after: retry_after)
      end

      def raise_http_request_error(response)
        raise HTTP::RequestError, "#{response.uri} => #{response.status} #{response.body} (#{response.headers.to_h})"
      end
    end
  end
end
