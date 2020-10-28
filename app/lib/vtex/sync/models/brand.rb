module Vtex
  module Sync
    module Models
      class Brand
        def initialize(additional_info_attributes)
          @additional_info_attributes = additional_info_attributes
        end

        def sync
          brand = find_or_initialize_vtex_brand
          brand.sync_attributes(additional_info_attributes)

          Logger.log_what_will_be_synced(brand)

          brand.save! if brand.changed?
          brand
        end

        private

        attr_reader :additional_info_attributes

        def find_or_initialize_vtex_brand
          attribute_brand_id = additional_info_attributes['brandId']
          Vtex::Brand.find_or_initialize_by identifier: attribute_brand_id
        end
      end
    end
  end
end
