module Vtex
  module Sync
    module Models
      class Total
        def initialize(total_attributes)
          @total_attributes = total_attributes
        end

        def sync
          total = find_or_initialize_vtex_total
          # Sobrescrevemos +id+ no hash para que o remap +id+ -> +identifier+ feito por
          # +sync_attributes+ preserve o identifier composto definido em +total_identifier+.
          total.sync_attributes(total_attributes.merge('id' => total_identifier))

          Logger.log_what_will_be_synced(total)

          total.save! if total.changed?
          total
        end

        private

        attr_reader :total_attributes

        def find_or_initialize_vtex_total
          Vtex::Total.find_or_initialize_by identifier: total_identifier
        end

        def total_identifier
          # +CustomTax+ aparece várias vezes no mesmo pedido (TAX, INSURANCE, FREIGHT). Compomos o
          # identifier com +name+ para diferenciar cada subcategoria no catálogo compartilhado.
          id = total_attributes['id']
          id == 'CustomTax' ? "#{id}:#{total_attributes['name']}" : id
        end
      end
    end
  end
end
