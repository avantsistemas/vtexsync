module Vtex
  module Sync
    module Models
      class Address
        include Fingerprintable

        # A VTEX só garante um +addressId+ estável e único por endereço quando ele vem no formato UUID. Em outros
        # formatos (numérico, alfanumérico curto) ela reaproveita o mesmo +addressId+ entre clientes diferentes, e em
        # marketplaces como o Mercado Livre ele chega como um rótulo ("Casa"). Nesses casos, usar o +addressId+ como
        # chave-única faz pedidos de clientes distintos colidirem no mesmo registro.
        UUID = /\A[a-f0-9]{32}\z/i
        UUID_DASHED = /\A[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}\z/i

        # Diferente dos demais sync models, recebe +order_code+ além de +attributes+: o fingerprint transacional
        # depende do +orderId+, que vive no topo do pedido e não dentro do objeto +shippingData.address+.
        def initialize(attributes, order_code:)
          @attributes = attributes
          @order_code = order_code
        end

        private

        attr_reader :attributes, :order_code

        def model_class
          Vtex::Address
        end

        def fingerprint
          address_id = attributes['addressId'].to_s
          return address_id if address_id.match?(UUID) || address_id.match?(UUID_DASHED)

          # Sem um identificador global confiável, tratamos o endereço como informação transacional do pedido.
          "#{order_code}:#{address_id}"
        end
      end
    end
  end
end
