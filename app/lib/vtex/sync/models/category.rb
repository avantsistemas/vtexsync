module Vtex
  module Sync
    module Models
      class Category
        include Fingerprintable

        def initialize(attributes)
          @attributes = attributes
        end

        private

        attr_reader :attributes

        def model_class
          Vtex::Category
        end

        def fingerprint
          attributes['id']
        end
      end
    end
  end
end
