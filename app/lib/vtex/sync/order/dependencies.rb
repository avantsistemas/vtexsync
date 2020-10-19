module Vtex
  module Sync
    class Order
      module Dependencies
        private

        def sync_dependencies(vtex_order)
          sync_client(vtex_order)
          sync_shipping_address(vtex_order)
        end

        def sync_client(vtex_order)
          vtex_client = Vtex::Sync::Client.new(client_attributes).sync
          vtex_order.client = vtex_client
        end

        def sync_shipping_address(vtex_order)
          vtex_address = Vtex::Sync::Address.new(shipping_address_attributes).sync
          vtex_order.shipping_address = vtex_address
        end

        def client_attributes
          order_attributes['clientProfileData']
        end

        def shipping_address_attributes
          order_attributes['shippingData']['address']
        end
      end
    end
  end
end
