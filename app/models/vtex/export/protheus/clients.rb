module Vtex
  module Export
    module Protheus
      class Clients
        def initialize(orders)
          @orders = orders
        end

        def to_txt
          @orders.map do |order|
            client = order.client
            address = order.address
            Client.new(client, address).to_txt
          end.join("\n")
        end
      end
    end
  end
end
