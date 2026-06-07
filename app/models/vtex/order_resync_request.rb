module Vtex
  # Solicitação durável de re-sincronização de um pedido. Substitui o antigo par
  # de colunas resync_requested_at/resync_reason em vtex_orders: cada marcação
  # vira uma linha aqui, e a baixa no sucesso preenche completed_at em vez de
  # apagar o registro — preservando o histórico (e o motivo) das re-sincronizações.
  class OrderResyncRequest < ApplicationRecord
    belongs_to :order, class_name: 'Vtex::Order'

    scope :pending, -> { where(completed_at: nil) }
    scope :completed, -> { where.not(completed_at: nil) }
  end
end
