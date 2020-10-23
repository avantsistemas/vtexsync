module Vtex
  module Sync
    module Models
      class Total
        def initialize(total_attributes)
          @total_attributes = total_attributes
        end

        def sync
          total = find_or_initialize_vtex_total
          total.sync_attributes(total_attributes)

          Logger.log_what_will_be_synced(total)

          total.save! if total.changed?
          total
        end

        def self.sync_all(totals_attributes)
          totals_attributes.map do |total_attributes|
            new(total_attributes).sync
          end
        end

        private

        attr_reader :total_attributes

        def find_or_initialize_vtex_total
          Vtex::Total.find_or_initialize_by identifier: attribute_id
        end

        def attribute_id
          total_attributes['id']
        end
      end
    end
  end
end
