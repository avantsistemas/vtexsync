module Vtex
  module Export
    module Protheus
      class OrderItems
        def initialize(order_items, protheus_order:)
          @order_items = order_items
          @protheus_order = protheus_order
        end

        def to_txt
          @order_items.map do |order_item|
            if order_item.kit?
              # A interface de Vtex::Component é praticamente idêntica à de Vtex::OrderItem, por isso podemos
              # usar a mesma classe de exportção de itens Vtex::Export::Protheus::OrderItems. Se a interface
              # do model mudar, precisaríamos criar uma classe de exportação específica para os componentes.
              OrderItems.new(order_item.components, protheus_order: @protheus_order).to_txt
            else
              OrderItem.new(order_item, protheus_order: @protheus_order).to_txt
            end
          end.join("\n")
        end
      end
    end
  end
end
