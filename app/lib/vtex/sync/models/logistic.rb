module Vtex
  module Sync
    module Models
      class Logistic
        include Dependencies

        def initialize(logistic_attributes, vtex_order:)
          @logistic_attributes = logistic_attributes
          @vtex_order = vtex_order
        end

        def sync
          load_vtex_logistic

          sync_dependencies
          sync_attributes

          # Encontramos pedidos sem informações de SLA. Ex: MLP-41514789983.
          # Nessa situação, não salvaremos o registro em `vtex_logistics`.
          return unless vtex_logistic.sla

          Logger.log_what_will_be_synced(vtex_logistic)

          vtex_logistic.save! if vtex_order.persisted? && vtex_logistic.changed?
          vtex_logistic
        end

        def self.sync_all(logistics_attributes, vtex_order:)
          logistics_attributes.map do |logistic_attributes|
            new(logistic_attributes, vtex_order: vtex_order).sync
          end
        end

        private

        attr_reader :logistic_attributes, :vtex_order, :vtex_logistic

        def load_vtex_logistic
          vtex_order_item = find_vtex_order_item
          @vtex_logistic = vtex_order_item.logistic || vtex_order_item.build_logistic
        end

        def find_vtex_order_item
          order_item_index = logistic_attributes['itemIndex'].to_i
          vtex_order.items.to_a.find { |item| item.index == order_item_index }
        end

        def sync_attributes
          vtex_logistic.sync_attributes(logistic_attributes)
        end
      end
    end
  end
end
