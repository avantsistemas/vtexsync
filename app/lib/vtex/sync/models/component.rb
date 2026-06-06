module Vtex
  module Sync
    module Models
      class Component
        include Dependencies

        def initialize(component_attributes, vtex_order_item:, index:)
          @component_attributes = component_attributes
          @vtex_order_item = vtex_order_item
          @index = index
        end

        def sync
          load_vtex_component

          sync_dependencies
          sync_attributes

          Logger.log_what_will_be_synced(vtex_component)

          vtex_component.save! if vtex_component.changed?
          vtex_component
        end

        def self.sync_all(components_attributes, vtex_order_item:)
          components_attributes.each_with_index.map do |component_attributes, index|
            new(component_attributes, vtex_order_item: vtex_order_item, index: index).sync
          end
        end

        private

        attr_reader :component_attributes, :vtex_component, :vtex_order_item

        def load_vtex_component
          attribute_unique_id = component_attributes['uniqueId']

          # Como "uniqueId" se repete entre componentes de um mesmo item (ex: 1075461974756-01), para
          # identificar unicamente o componente, usamos, além do "uniqueId", o código do item e o índice
          # do componente dentro do item.
          @vtex_component = vtex_order_item.components.find_or_initialize_by identifier: attribute_unique_id,
                                                                             index: @index
        end

        def sync_attributes
          vtex_component.sync_attributes(component_attributes)
        end
      end
    end
  end
end
