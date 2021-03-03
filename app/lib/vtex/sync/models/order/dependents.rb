module Vtex
  module Sync
    module Models
      class Order
        module Dependents
          private

          def sync_dependents
            sync_sellers
            sync_order_totals
            sync_campaigns
            sync_order_items
            sync_order_benefits
            sync_order_logistics
            sync_transactions
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

          def sync_campaigns
            campaign_attributes = order_attributes['marketingData']
            # existem pedidos sem atributos de marketing. Ex: 1075252714422-01.
            Campaign.new(campaign_attributes, vtex_order: vtex_order).sync if campaign_attributes
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

          # As informações de shippingData > logisticsInfo são dependentes dos itens do pedido. Porém a forma como essa
          # informação está estruturada no JSON de pedidos da VTEX nos impede de fazer a sincronização no momento da
          # sincronização dos itens.
          def sync_order_logistics
            logistics_attributes = order_attributes['shippingData']['logisticsInfo']

            logistics = Logistic.sync_all(logistics_attributes,
                                          vtex_order: vtex_order)

            destroy_not_synced(logistics, scope: vtex_order.logistics)
          end

          def sync_transactions
            transactions_attributes = order_attributes['paymentData']['transactions']

            transactions = Transaction.sync_all(transactions_attributes,
                                                vtex_order: vtex_order)

            destroy_not_synced(transactions, scope: vtex_order.transactions)
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
