module Vtex
  module Sync
    module Models
      class PaymentSystem
        def initialize(payment_attributes)
          @payment_attributes = payment_attributes
        end

        def sync
          payment_system = find_or_initialize_vtex_payment_system
          payment_system.sync_attributes(payment_attributes)

          Logger.log_what_will_be_synced(payment_system)

          payment_system.save! if payment_system.changed?
          payment_system
        end

        private

        attr_reader :payment_attributes

        def find_or_initialize_vtex_payment_system
          attribute_payment_system = payment_attributes['paymentSystem']
          Vtex::PaymentSystem.find_or_initialize_by identifier: attribute_payment_system
        end
      end
    end
  end
end
