module Vtex
  module Sync
    module Models
      class OrderBenefit
        def initialize(rate_and_benefits_identifier_attributes, vtex_order:)
          @rate_and_benefits_identifier_attributes = rate_and_benefits_identifier_attributes
          @vtex_order = vtex_order
        end

        def sync
          order_benefit = find_or_initialize_vtex_order_benefit

          Logger.log_what_will_be_synced(order_benefit)

          order_benefit.save! if order_benefit.changed?
          order_benefit
        end

        def self.sync_all(rate_and_benefits_identifiers_attributes, vtex_order:)
          rate_and_benefits_identifiers_attributes.map do |rate_and_benefits_identifier_attributes|
            new(rate_and_benefits_identifier_attributes, vtex_order: vtex_order).sync
          end
        end

        private

        attr_reader :rate_and_benefits_identifier_attributes, :vtex_order

        def find_or_initialize_vtex_order_benefit
          benefit = Benefit.new(rate_and_benefits_identifier_attributes).sync
          vtex_order.order_benefits.find_or_initialize_by benefit: benefit
        end
      end
    end
  end
end
