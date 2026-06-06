module Vtex
  module Sync
    module Models
      class PaymentSystem
        include Fingerprintable

        def initialize(attributes)
          @attributes = attributes
        end

        private

        attr_reader :attributes

        def model_class
          Vtex::PaymentSystem
        end

        def fingerprint
          attributes['paymentSystem']
        end
      end
    end
  end
end
