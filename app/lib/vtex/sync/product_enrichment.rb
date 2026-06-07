module Vtex
  module Sync
    # Completa um produto já sincronizado com os atributos que só o catálogo
    # expõe (kit, ativo, data de criação), buscados por SKU. Espelha a forma do
    # +Sync::Order+: o orquestrador é dono do client e faz o fetch de rede fora
    # de qualquer transação aberta.
    class ProductEnrichment
      delegate :logger, to: Rails

      # Conveniência para chamadas avulsas (rake, job): constrói o client. Em
      # lote, prefira a forma de instância para reaproveitar o mesmo client
      # (conexão e estado de cooldown) entre os produtos.
      def self.call(product, api_client: Vtex::Api::Client.build)
        new(api_client).call(product)
      end

      def initialize(api_client)
        @api_client = api_client
      end

      def call(product)
        logger.info "Enriquecendo produto SKU #{product.sku_code}"

        sku_attributes = @api_client.get_sku(product.sku_code)

        product.update!(
          kit: sku_attributes['IsKit'],
          active: sku_attributes['IsActive'],
          creation_date: sku_attributes['CreationDate']
        )
        product
      end
    end
  end
end
