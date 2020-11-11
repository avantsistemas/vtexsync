module Vtex
  class Payment < ApplicationRecord
    include Synchronizable
    has_paper_trail

    # não foi possível usar o nome `transaction` por ele já ser um método do ActiveRecord
    belongs_to :agreement, class_name: 'Vtex::Transaction', foreign_key: :transaction_id,
                           inverse_of: :payments, optional: true
    # sem o optional acima, dá erro de validação ao tentar salvar
    # um novo pedido (order <- transactions <- payments)

    belongs_to :payment_system
    has_one :connector_response, dependent: :destroy

    sync_attributes :id, :value, :installments

    remap_attributes id: :identifier,
                     value: :value_in_cents

    def value_in_cents=(value_in_cents)
      self.value = value_in_cents ? value_in_cents.to_d / 100 : nil
    end
  end
end
