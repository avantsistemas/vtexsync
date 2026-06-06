module Vtex
  module Sync
    module Models
      class Total
        include Fingerprintable

        def initialize(attributes)
          @attributes = attributes
        end

        private

        attr_reader :attributes

        def model_class
          Vtex::Total
        end

        def fingerprint
          # +CustomTax+ aparece várias vezes no mesmo pedido (TAX, INSURANCE, FREIGHT). Compomos o
          # identifier com +name+ para diferenciar cada subcategoria no catálogo compartilhado.
          id = attributes['id']
          id == 'CustomTax' ? "#{id}:#{attributes['name']}" : id
        end
      end
    end
  end
end
