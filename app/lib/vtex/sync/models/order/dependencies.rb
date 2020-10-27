module Vtex
  module Sync
    module Models
      class Order
        module Dependencies
          private

          def sync_dependencies
            sync_client
            sync_shipping_address
          end

          def sync_client
            client_attributes = order_attributes['clientProfileData']
            vtex_client = Client.new(client_attributes).sync
            vtex_order.client = vtex_client
          end

          def sync_shipping_address
            shipping_address_attributes = order_attributes['shippingData']['address']
            vtex_address = Address.new(shipping_address_attributes).sync
            vtex_order.shipping_address = vtex_address
          end
        end
      end
    end
  end
end
