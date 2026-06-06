module Vtex
  module Sync
    module Models
      class Payment
        include Identifiable
        include Dependencies
        include Dependents

        def initialize(payment_attributes, vtex_transaction:)
          @payment_attributes = payment_attributes
          @vtex_transaction = vtex_transaction
        end

        def sync
          load_vtex_payment

          sync_dependencies
          sync_attributes

          Logger.log_what_will_be_synced(vtex_payment)

          vtex_payment.save! if vtex_payment.changed?

          sync_dependents
          vtex_payment
        end

        def self.sync_all(payments_attributes, vtex_transaction:)
          payments_attributes.map do |payment_attributes|
            new(payment_attributes, vtex_transaction: vtex_transaction).sync
          end
        end

        private

        attr_reader :payment_attributes, :vtex_payment, :vtex_transaction

        def load_vtex_payment
          @vtex_payment = find_or_initialize_record
        end

        def fingerprint
          payment_attributes['id']
        end

        def identity_scope
          vtex_transaction.payments
        end

        def sync_attributes
          vtex_payment.sync_attributes(payment_attributes)
        end
      end
    end
  end
end
