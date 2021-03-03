module Vtex
  module Sync
    module Models
      class OrderItem
        include Dependencies
        include Dependents

        def initialize(order_item_attributes, vtex_order:, index:)
          @order_item_attributes = order_item_attributes
          @vtex_order = vtex_order
          @index = index
        end

        def sync
          load_vtex_order_item

          sync_dependencies
          sync_dependents
          sync_attributes

          Logger.log_what_will_be_synced(vtex_order_item)

          vtex_order_item.save! if vtex_order.persisted? && vtex_order_item.changed?
          vtex_order_item
        end

        def self.sync_all(order_items_attributes, vtex_order:)
          order_items_attributes.each_with_index.map do |order_item_attributes, index|
            new(order_item_attributes, vtex_order: vtex_order, index: index).sync
          end
        end

        private

        attr_reader :order_item_attributes, :vtex_order_item, :vtex_order

        def load_vtex_order_item
          attribute_unique_id = order_item_attributes['uniqueId']

          # Como "uniqueId" se repete entre itens de um mesmo pedido (ex: 1064230768540-01, 1065732673793-01,
          # 1066163355534-01) e também entre pedidos diferentes (ex: 1068192373206-01, 1068192373206-01), para
          # identificar unicamente o item, usamos, além do "uniqueId", o código do pedido e o índice do item
          # dentro do pedido.
          @vtex_order_item = vtex_order.items.find_or_initialize_by identifier: attribute_unique_id, index: @index
        end

        def sync_attributes
          vtex_order_item.sync_attributes(order_item_attributes)
          # Para facilitar algumas pesquisa e análises, adicionamos o atributo `kit`
          # ao modelo `Vtex::OrderItem` para indicar se aquele item é ou não um kit.
          vtex_order_item.kit = order_item_attributes['components'].any?
        end
      end
    end
  end
end
