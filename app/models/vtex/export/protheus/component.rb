module Vtex
  module Export
    module Protheus
      class Component < Exportable
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
          @order_item.discount
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
