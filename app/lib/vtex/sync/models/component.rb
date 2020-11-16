module Vtex
  module Sync
    module Models
      class Component
        include Dependencies

        def initialize(component_attributes, vtex_order_item:)
          @component_attributes = component_attributes
          @vtex_order_item = vtex_order_item
        end

        def sync
          load_vtex_component

          sync_dependencies
          sync_attributes

          Logger.log_what_will_be_synced(vtex_component)

          vtex_component.save! if vtex_order_item.persisted? && vtex_component.changed?
          vtex_component
        end

        def self.sync_all(components_attributes, vtex_order_item:)
          components_attributes.map do |component_attributes|
            new(component_attributes, vtex_order_item: vtex_order_item).sync
          end
        end

        private

        attr_reader :component_attributes, :vtex_component, :vtex_order_item

        def load_vtex_component
          attribute_unique_id = component_attributes['uniqueId']
          attribute_quantity = component_attributes['quantity']
          attribute_selling_price = component_attributes['sellingPrice'].to_d / 100

          # Existem componentes onde a propriedade uniqueId se repete entre os itens. Ex: 1075461974756-01,
          # Por isso, `order_item_id` e `selling_price` foram adicionadas para tentar garantir a unicidade.
          @vtex_component = vtex_order_item.components.find_or_initialize_by identifier: attribute_unique_id,
                                                                             quantity: attribute_quantity,
                                                                             selling_price: attribute_selling_price
        end

        def sync_attributes
          vtex_component.sync_attributes(component_attributes)
        end
      end
    end
  end
end
