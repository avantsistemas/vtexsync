module Vtex
  module Orders
    class ResyncEnqueuer
      def self.call(limit: nil)
        pending = Vtex::Order.pending_resync
        pending = pending.limit(limit) if limit&.positive?

        total = pending.count
        enqueued = 0
        pending.find_each do |order|
          Vtex::Order::SyncJob.perform_later(order.order_code)
          enqueued += 1
        end

        { total: total, enqueued: enqueued }
      end
    end
  end
end
