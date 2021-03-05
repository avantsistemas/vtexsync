module Vtex
  module Export
    module Protheus
      class OrderItem
        COL_SEP = ';'.freeze
        SEP_REP = ','.freeze

        def initialize(order_item, protheus_order:)
          @order_item = order_item
          @protheus_order = protheus_order
        end

        def to_txt
          prepared_order_item_data.join(COL_SEP)
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

        def prepared_order_item_data
          order_item_data.map do |info|
            info.to_s.upcase.tr(COL_SEP, SEP_REP)
          end
        end

        def order_item_data
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
