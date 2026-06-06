module Vtex
  module Sync
    module Models
      class Client
        include Fingerprintable

        def initialize(attributes)
          @attributes = attributes
        end

        private

        attr_reader :attributes

        def model_class
          Vtex::Client
        end

        def fingerprint
          # Usávamos +userProfileId+ como identificador único do cliente. Porém, em pedidos do Mercado Livre,
          # +userProfileId+ vem nulo. Para casos assim, usaremos +document+ ou +corporateDocument+ como identificador.
          attributes['userProfileId'].presence ||
            attributes['document'].presence ||
            attributes['corporateDocument'].presence
        end
      end
    end
  end
end
