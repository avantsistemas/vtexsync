module Vtex
  module Orders
    class ResyncMarker
      def self.call(order_codes: nil, scope: nil, from: nil, to: nil, reason: nil)
        order_ids = filtered_orders(order_codes: order_codes, scope: scope, from: from, to: to).pluck(:id)
        return 0 if order_ids.empty?

        upsert_requests(order_ids, reason)
        order_ids.size
      end

      def self.filtered_orders(order_codes:, scope:, from:, to:)
        relation = Vtex::Order.all
        relation = relation.where(order_code: order_codes) if order_codes&.any?
        relation = relation.where(scope) if scope.present?
        relation = relation.where(creation_date: from..to) if from || to

        raise ArgumentError, 'informe ao menos um filtro: order_codes, scope ou from/to' if relation == Vtex::Order.all

        relation
      end
      private_class_method :filtered_orders

      # Abre um request por pedido, mas atualiza o request já em aberto em vez de
      # empilhar outro — o enfileiramento é por pedido, não por request.
      def self.upsert_requests(order_ids, reason)
        now = Time.current
        open_requests = Vtex::OrderResyncRequest.pending.where(order_id: order_ids)
        already_open_ids = open_requests.pluck(:order_id)
        open_requests.update_all(requested_at: now, reason: reason, updated_at: now)

        new_order_ids = order_ids - already_open_ids
        return if new_order_ids.empty?

        Vtex::OrderResyncRequest.insert_all(
          new_order_ids.map do |order_id|
            { order_id: order_id, requested_at: now, reason: reason, created_at: now, updated_at: now }
          end
        )
      end
      private_class_method :upsert_requests
    end
  end
end
