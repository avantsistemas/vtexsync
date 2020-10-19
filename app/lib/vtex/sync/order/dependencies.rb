module Vtex
  module Sync
    class Order
      module Dependencies
        private

        def sync_dependencies(vtex_order)
          sync_client(vtex_order)
        end

        def sync_client(vtex_order)
          vtex_client = Vtex::Sync::Client.new(client_attributes).sync
          vtex_order.client = vtex_client
        end

        def client_attributes
          order_attributes['clientProfileData']
        end
      end
    end
  end
end
