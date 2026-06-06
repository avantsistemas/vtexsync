module Vtex
  module Sync
    module Models
      class Order
        include Dependencies
        include Dependents

        def initialize(order_attributes)
          @order_attributes = order_attributes
        end

        def sync
          load_vtex_order

          sync_dependencies
          sync_attributes

          Logger.log_what_will_be_synced(vtex_order)

          # Persistimos o pedido antes dos dependentes para que cada filho
          # (itens, totais, transações...) sempre encontre o pai já gravado.
          # A atomicidade fica por conta da transação em Vtex::Sync::Order.
          vtex_order.save! if vtex_order.changed?

          sync_dependents
          vtex_order
        end

        private

        attr_reader :order_attributes, :vtex_order

        def load_vtex_order
          attribute_order_id = order_attributes['orderId']
          @vtex_order = Vtex::Order.find_or_initialize_by order_code: attribute_order_id
        end

        def sync_attributes
          vtex_order.sync_attributes(order_attributes)
        end
      end
    end
  end
end
