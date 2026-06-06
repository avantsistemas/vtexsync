module Vtex
  module Sync
    module Models
      class Sla
        include Fingerprintable

        def initialize(attributes)
          @attributes = attributes
        end

        private

        attr_reader :attributes

        def model_class
          Vtex::Sla
        end

        def fingerprint
          attributes['id']
        end
      end
    end
  end
end
