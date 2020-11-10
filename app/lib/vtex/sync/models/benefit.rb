module Vtex
  module Sync
    module Models
      class Benefit
        def initialize(benefit_attributes)
          @benefit_attributes = benefit_attributes
        end

        def sync
          benefit = find_or_initialize_vtex_benefit
          benefit.sync_attributes(benefit_attributes)

          Logger.log_what_will_be_synced(benefit)

          benefit.save! if benefit.changed?
          benefit
        end

        private

        attr_reader :benefit_attributes

        def find_or_initialize_vtex_benefit
          attribute_id = benefit_attributes['id']
          Vtex::Benefit.find_or_initialize_by identifier: attribute_id
        end
      end
    end
  end
end
