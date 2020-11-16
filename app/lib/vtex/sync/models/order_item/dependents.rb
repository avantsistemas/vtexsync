module Vtex
  module Sync
    module Models
      class OrderItem
        module Dependents
          private

          def sync_dependents
            sync_components
          end

          def sync_components
            components_attributes = order_item_attributes['components']

            return unless components_attributes

            components = Component.sync_all(components_attributes,
                                            vtex_order_item: vtex_order_item)

            destroy_not_synced(components, scope: vtex_order_item.components)
          end

          def destroy_not_synced(synced_models, scope:)
            return if vtex_order_item.new_record?

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
