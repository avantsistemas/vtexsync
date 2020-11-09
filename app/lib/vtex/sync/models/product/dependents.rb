module Vtex
  module Sync
    module Models
      class Product
        module Dependents
          private

          def sync_dependents
            sync_products_categories
          end

          def sync_products_categories
            product_categories_attributes = order_item_attributes['additionalInfo']['categories']

            product_categories = ProductCategory.sync_all(product_categories_attributes,
                                                          vtex_product: vtex_product)

            destroy_not_synced(product_categories, scope: vtex_product.product_categories)
          end

          def destroy_not_synced(synced_models, scope:)
            return if vtex_product.new_record?

            not_synced_models = scope.where.not(id: synced_models)

            not_synced_models.each do |not_synced_model|
              Logger.log_model_will_be_destroyed(not_synced_model)
              not_synced_model.destroy!
            end
          end
        end
      end
    end
  end
end
