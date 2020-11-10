module Vtex
  module Sync
    module Models
      class MarketingDatum
        def initialize(marketing_datum_attributes, vtex_order:)
          @marketing_datum_attributes = marketing_datum_attributes
          @vtex_order = vtex_order
        end

        def sync
          marketing_datum = find_or_initialize_vtex_marketing_datum
          marketing_datum.sync_attributes(marketing_datum_attributes)

          Logger.log_what_will_be_synced(marketing_datum)

          marketing_datum.save! if vtex_order.persisted? && marketing_datum.changed?
          marketing_datum
        end

        private

        attr_reader :marketing_datum_attributes, :vtex_order

        def find_or_initialize_vtex_marketing_datum
          vtex_order.marketing_datum || vtex_order.build_marketing_datum
        end
      end
    end
  end
end
