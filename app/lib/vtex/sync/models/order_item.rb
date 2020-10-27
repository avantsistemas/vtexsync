module Vtex
  module Sync
    module Models
      class OrderItem
        include Dependencies

        def initialize(order_item_attributes, vtex_order:)
          @order_item_attributes = order_item_attributes
          @vtex_order = vtex_order
        end

        def sync
          load_vtex_order_item

          sync_dependencies
          sync_attributes

          Logger.log_what_will_be_synced(vtex_order_item)

          vtex_order_item.save! if vtex_order.persisted? && vtex_order_item.changed?
          vtex_order_item
        end

        def self.sync_all(order_items_attributes, vtex_order:)
          order_items_attributes.map do |order_item_attributes|
            new(order_item_attributes, vtex_order: vtex_order).sync
          end
        end

        private

        attr_reader :order_item_attributes, :vtex_order_item, :vtex_order

        def load_vtex_order_item
          attribute_unique_id = order_item_attributes['uniqueId']
          attribute_quantity = order_item_attributes['quantity']
          attribute_selling_price = order_item_attributes['sellingPrice'].to_d / 100

          # Existem pedidos onde a propriedade uniqueId se repete entre os itens. Ex: 1064230768540-01,
          # 1065732673793-01 e 1066163355534-01. E também existem pedidos diferentes com itens com uniqueId
          # repetido. Ex: 1068192373206-01 e 1068192373206-01. Por isso, `order_id` e `selling_price` foram
          # adicionadas para tentar garantir a unicidade.
          @vtex_order_item = vtex_order.items.find_or_initialize_by identifier: attribute_unique_id,
                                                                    quantity: attribute_quantity,
                                                                    selling_price: attribute_selling_price
        end

        def sync_attributes
          vtex_order_item.sync_attributes(order_item_attributes)
        end
      end
    end
  end
end
