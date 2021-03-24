module Vtex
  module Export
    module Protheus
      class OrderItem < Exportable
        def initialize(order_item, protheus_order:)
          @order_item = order_item
          @protheus_order = protheus_order
        end

        def item_sequence
          format('%<sequence>02d', sequence: @protheus_order.next_item_sequence)
        end

        def product_ean
          @order_item.product.ean
        end

        def quantity
          @order_item.quantity
        end

        def gift
          @order_item.gift? ? 'S' : 'N'
        end

        def price
          @order_item.price
        end

        def discount
          # Para fins de exportação do TXT de pedidos, se o item for brinde, o desconto deve
          # ser zero. Caso contrário, o desconto deve ser o (price - selling_price) * quantity)
          @order_item.gift? ? 0 : ((@order_item.price - @order_item.selling_price) * @order_item.quantity)
        end

        private

        def data_array
          [
            'B',
            item_sequence,
            product_ean,
            quantity,
            gift,
            price,
            discount
          ]
        end
      end
    end
  end
end
