module Vtex
  module Sync
    module Models
      class Transaction
        # include Dependencies

        def initialize(transaction_attributes, vtex_order:)
          @transaction_attributes = transaction_attributes
          @vtex_order = vtex_order
        end

        def sync
          load_vtex_transaction

          # sync_dependencies
          sync_attributes

          Logger.log_what_will_be_synced(vtex_transaction)

          vtex_transaction.save! if vtex_order.persisted? && vtex_transaction.changed?
          vtex_transaction
        end

        def self.sync_all(transactions_attributes, vtex_order:)
          transactions_attributes.map do |transaction_attributes|
            new(transaction_attributes, vtex_order: vtex_order).sync
          end
        end

        private

        attr_reader :transaction_attributes, :vtex_transaction, :vtex_order

        def load_vtex_transaction
          attribute_transaction_id = transaction_attributes['transactionId']
          @vtex_transaction = vtex_order.transactions.find_or_initialize_by identifier: attribute_transaction_id
        end

        def sync_attributes
          vtex_transaction.sync_attributes(transaction_attributes)
        end
      end
    end
  end
end
