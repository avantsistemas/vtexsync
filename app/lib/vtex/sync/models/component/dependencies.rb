module Vtex
  module Sync
    module Models
      class Component
        module Dependencies
          private

          def sync_dependencies
            sync_product
          end

          def sync_product
            product_attributes = component_attributes

            # As informações sobre o produto do componente são incompletas. Por isso optamos
            # por disparar a sincronização apenas se o produto ainda não tiver sido cadastrado.

            vtex_product = Vtex::Product.find_by identifier: product_attributes['refId']
            vtex_product ||= Product.new(product_attributes).sync

            vtex_component.product = vtex_product
          end
        end
      end
    end
  end
end
