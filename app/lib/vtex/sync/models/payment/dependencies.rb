module Vtex
  module Sync
    module Models
      class Payment
        module Dependencies
          private

          def sync_dependencies
            sync_payment_system
          end

          def sync_payment_system
            vtex_payment_system = PaymentSystem.new(payment_attributes).sync
            vtex_payment.payment_system = vtex_payment_system
          end
        end
      end
    end
  end
end
