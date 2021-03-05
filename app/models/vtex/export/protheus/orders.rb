module Vtex
  module Export
    module Protheus
      class Orders
        def initialize(orders)
          @orders = orders
        end

        def to_txt
          @orders.map do |order|
            Order.new(order).to_txt
          end.join("\n")
        end
      end
    end
  end
end
