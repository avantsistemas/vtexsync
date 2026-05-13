module Vtex
  module Orders
    class ResyncMarker
      def self.call(order_codes: nil, scope: nil, from: nil, to: nil, reason: nil)
        relation = Vtex::Order.all
        relation = relation.where(order_code: order_codes) if order_codes&.any?
        relation = relation.where(scope) if scope.present?
        relation = relation.where(creation_date: from..to) if from || to

        raise ArgumentError, 'informe ao menos um filtro: order_codes, scope ou from/to' if relation == Vtex::Order.all

        relation.update_all(resync_requested_at: Time.current, resync_reason: reason)
      end
    end
  end
end
