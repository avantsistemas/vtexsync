module Vtex
  module Sync
    module Models
      class Sla
        def initialize(sla_attributes)
          @sla_attributes = sla_attributes
        end

        def sync
          sla = find_or_initialize_vtex_sla
          sla.sync_attributes(sla_attributes)

          Logger.log_what_will_be_synced(sla)

          sla.save! if sla.changed?
          sla
        end

        private

        attr_reader :sla_attributes

        def find_or_initialize_vtex_sla
          attribute_id = sla_attributes['id']
          Vtex::Sla.find_or_initialize_by identifier: attribute_id
        end
      end
    end
  end
end
