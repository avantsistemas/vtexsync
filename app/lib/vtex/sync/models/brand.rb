module Vtex
  module Sync
    module Models
      class Brand
        include Fingerprintable

        def initialize(attributes)
          @attributes = attributes
        end

        private

        attr_reader :attributes

        def model_class
          Vtex::Brand
        end

        def fingerprint
          attributes['brandId']
        end
      end
    end
  end
end
