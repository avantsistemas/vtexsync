module Vtex
  module Api
    # Levantado quando a VTEX responde 429 Too Many Requests. Carrega o
    # tempo sugerido de espera (header Retry-After), em segundos, para
    # fins de observabilidade e backoff.
    class RateLimitError < StandardError
      attr_reader :retry_after

      def initialize(retry_after:)
        @retry_after = retry_after
        super("VTEX respondeu 429 Too Many Requests (Retry-After: #{retry_after}s)")
      end
    end
  end
end
