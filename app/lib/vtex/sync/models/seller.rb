module Vtex
  module Sync
    module Models
      class Seller
        include Fingerprintable

        def initialize(attributes)
          @attributes = attributes
        end

        def self.sync_all(sellers_attributes)
          sellers_attributes.map do |seller_attributes|
            new(seller_attributes).sync
          end
        end

        private

        attr_reader :attributes

        def model_class
          Vtex::Seller
        end

        def fingerprint
          attributes['id']
        end
      end
    end
  end
end
