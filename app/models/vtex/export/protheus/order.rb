module Vtex
  module Export
    module Protheus
      class Order
        COL_SEP = ';'.freeze
        SEP_REP = ','.freeze

        def initialize(order)
          @order = order
          @item_sequence = 0
        end

        def to_txt
          prepared_order_data.join(COL_SEP) + "\n" + OrderItems.new(@order.items, protheus_order: self).to_txt
        end

        def limited_order_code
          @order.order_code[0..9]
        end

        def client_document
          @order.client.document
        end

        def client_postal_code
          @order.address.postal_code.gsub(/\W/, '')
        end

        def next_item_sequence
          @item_sequence += 1
        end

        private

        def prepared_order_data
          order_data.map do |info|
            info.to_s.upcase.tr(COL_SEP, SEP_REP)
          end
        end

        def order_data
          [
            'A',
            limited_order_code,
            client_document,
            'EC1',
            client_postal_code
          ]
        end
      end
    end
  end
end
