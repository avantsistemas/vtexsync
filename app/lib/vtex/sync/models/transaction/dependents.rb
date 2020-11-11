module Vtex
  module Sync
    module Models
      class Transaction
        module Dependents
          private

          def sync_dependents
            sync_payments
          end

          def sync_payments
            payments_attributes = transaction_attributes['payments']

            payments = Payment.sync_all(payments_attributes, vtex_transaction: vtex_transaction)

            destroy_not_synced(payments, scope: vtex_transaction.payments)
          end

          def destroy_not_synced(synced_models, scope:)
            return if vtex_transaction.new_record?

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
