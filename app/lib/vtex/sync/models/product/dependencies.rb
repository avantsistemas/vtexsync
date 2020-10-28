module Vtex
  module Sync
    module Models
      class Product
        module Dependencies
          private

          def sync_dependencies
            sync_brand
          end

          def sync_brand
            additional_info_attributes = order_item_attributes['additionalInfo']
            vtex_brand = Brand.new(additional_info_attributes).sync
            vtex_product.brand = vtex_brand
          end
        end
      end
    end
  end
end
