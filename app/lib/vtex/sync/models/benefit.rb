module Vtex
  module Sync
    module Models
      class Benefit
        include Fingerprintable

        def initialize(attributes)
          @attributes = attributes
        end

        private

        attr_reader :attributes

        def model_class
          Vtex::Benefit
        end

        def fingerprint
          attributes['id']
        end
      end
    end
  end
end
