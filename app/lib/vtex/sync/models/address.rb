module Vtex
  module Sync
    module Models
      class Address
        # A VTEX só garante um +addressId+ estável e único por endereço quando ele vem no formato UUID. Em outros
        # formatos (numérico, alfanumérico curto) ela reaproveita o mesmo +addressId+ entre clientes diferentes, e em
        # marketplaces como o Mercado Livre ele chega como um rótulo ("Casa"). Nesses casos, usar o +addressId+ como
        # chave-única faz pedidos de clientes distintos colidirem no mesmo registro.
        UUID = /\A[a-f0-9]{32}\z/i
        UUID_DASHED = /\A[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}\z/i

        def initialize(address_attributes, order_code:)
          @address_attributes = address_attributes
          @order_code = order_code
        end

        def sync
          address = find_or_initialize_vtex_address
          # Sobrescrevemos +addressId+ no hash para que o remap +addressId+ -> +identifier+ feito por
          # +sync_attributes+ preserve o identifier transacional definido em +address_identifier+.
          address.sync_attributes(address_attributes.merge('addressId' => address_identifier))

          Logger.log_what_will_be_synced(address)

          address.save! if address.changed?
          address
        end

        private

        attr_reader :address_attributes, :order_code

        def find_or_initialize_vtex_address
          Vtex::Address.find_or_initialize_by identifier: address_identifier
        end

        def address_identifier
          address_id = address_attributes['addressId'].to_s
          return address_id if address_id.match?(UUID) || address_id.match?(UUID_DASHED)

          # Sem um identificador global confiável, tratamos o endereço como informação transacional do pedido.
          "#{order_code}:#{address_id}"
        end
      end
    end
  end
end
