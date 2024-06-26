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
              # usar a mesma classe de exportação de itens Vtex::Export::Protheus::OrderItems. Se a interface
              # do model mudar, precisaríamos criar uma classe de exportação específica para os componentes.
              # Parece que no objeto `component` no JSON do pedido da VTEX, a quantidade indica a quantidade
              # daquele produto na composição do kit. Sendo assim, precisamos multiplier essa quntidade pela
              # quantidade de kits comprados. Como ainda não queremos criar outra classe de exportação para
              # os componentes, usaremos o hack abaixo.
              order_item.components.each { |componenet| componenet.quantity *= order_item.quantity }
              OrderItems.new(order_item.components, protheus_order: @protheus_order).to_txt
            elsif order_item.product.ean? # Itens sem EAN (exceto os kits) não devem ser incluídos no TXT
              OrderItem.new(order_item, protheus_order: @protheus_order).to_txt
            end
          end.compact.join("\n")
        end
      end
    end
  end
end
