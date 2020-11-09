module Vtex
  module Sync
    module Models
      class Category
        def initialize(category_attributes)
          @category_attributes = category_attributes
        end

        def sync
          category = find_or_initialize_vtex_category
          category.sync_attributes(category_attributes)

          Logger.log_what_will_be_synced(category)

          category.save! if category.changed?
          category
        end

        private

        attr_reader :category_attributes

        def find_or_initialize_vtex_category
          attribute_id = category_attributes['id']
          Vtex::Category.find_or_initialize_by identifier: attribute_id
        end
      end
    end
  end
end
