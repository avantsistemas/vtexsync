module Vtex
  module Sync
    module Models
      class Transaction
        include Identifiable
        include Dependents

        def initialize(transaction_attributes, vtex_order:)
          @transaction_attributes = transaction_attributes
          @vtex_order = vtex_order
        end

        def sync
          return if no_transaction?

          load_vtex_transaction

          sync_attributes

          Logger.log_what_will_be_synced(vtex_transaction)

          vtex_transaction.save! if vtex_transaction.changed?

          sync_dependents
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
          @vtex_transaction = find_or_initialize_record
        end

        def fingerprint
          transaction_attributes['transactionId']
        end

        def identity_scope
          vtex_order.transactions
        end

        def sync_attributes
          vtex_transaction.sync_attributes(transaction_attributes)
        end

        def no_transaction?
          # Por algum motivo, quando não há transação para um determinado pedido, a API da VTEX está retornando
          # uma transação com transactionId == NO-PAYMENT em vez de retornar uma lista vazia em `transactions`.
          # Para não precisar alterar a chave única da nossa tabela `vtex_transactions`, não iremos salvar
          # nenhum registro de transação para esses casos de pedidos sem pagamento.
          return false if transaction_attributes['transactionId'] != 'NO-PAYMENT'

          Rails.logger.warn 'pedido sem transação/pagamento'
          true
        end
      end
    end
  end
end
