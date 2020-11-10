module Vtex
  module Sync
    module Models
      class Order
        module Dependents
          private

          def sync_dependents
            sync_sellers
            sync_order_totals
            sync_marketing_data
            sync_order_items
            sync_order_benefits
          end

          def sync_sellers
            sellers_attributes = order_attributes['sellers']
            Seller.sync_all(sellers_attributes)
          end

          def sync_order_totals
            order_totals_attributes = order_attributes['totals']

            order_totals = OrderTotal.sync_all(order_totals_attributes,
                                               vtex_order: vtex_order)

            destroy_not_synced(order_totals, scope: vtex_order.totals)
          end

          def sync_marketing_data
            marketing_datum_attributes = order_attributes['marketingData']
            # existem pedidos sem atributos de marketing. Ex: 1075252714422-01.
            MarketingDatum.new(marketing_datum_attributes, vtex_order: vtex_order).sync if marketing_datum_attributes
          end

          def sync_order_items
            order_items_attributes = order_attributes['items']

            order_items = OrderItem.sync_all(order_items_attributes,
                                             vtex_order: vtex_order)

            destroy_not_synced(order_items, scope: vtex_order.items)
          end

          def sync_order_benefits
            rates_and_benefits_data_attributes = order_attributes['ratesAndBenefitsData']
            rate_and_benefits_identifiers_attributes = rates_and_benefits_data_attributes['rateAndBenefitsIdentifiers']

            order_benefits = OrderBenefit.sync_all(rate_and_benefits_identifiers_attributes,
                                                   vtex_order: vtex_order)

            destroy_not_synced(order_benefits, scope: vtex_order.order_benefits)
          end

          def destroy_not_synced(synced_models, scope:)
            return if vtex_order.new_record?

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
