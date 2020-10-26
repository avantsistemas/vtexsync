module Vtex
  module Sync
    module Models
      class Seller
        def initialize(seller_attributes)
          @seller_attributes = seller_attributes
        end

        def sync
          seller = find_or_initialize_vtex_seller
          seller.sync_attributes(seller_attributes)

          Logger.log_what_will_be_synced(seller)

          seller.save! if seller.changed?
          seller
        end

        def self.sync_all(sellers_attributes)
          sellers_attributes.map do |seller_attributes|
            new(seller_attributes).sync
          end
        end

        private

        attr_reader :seller_attributes

        def find_or_initialize_vtex_seller
          Vtex::Seller.find_or_initialize_by identifier: attribute_id
        end

        def attribute_id
          seller_attributes['id']
        end
      end
    end
  end
end
