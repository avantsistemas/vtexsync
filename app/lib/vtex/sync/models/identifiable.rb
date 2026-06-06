module Vtex
  module Sync
    module Models
      # Resolve a identidade de um objeto do JSON de pedidos da VTEX: localiza ou inicializa o registro pela sua
      # chave-única, gravada na coluna +identifier+. Cada classe define +fingerprint+ (a regra de unicidade própria
      # daquele objeto) e, quando o registro é aninhado, +identity_scope+ (a associação do pai onde procurar) e
      # +identity_keys+ (colunas que, junto com o +identifier+, compõem a chave — ex: o índice do item no pedido).
      #
      # Por padrão a busca acontece no catálogo global da +model_class+ e sem chaves adicionais, atendendo aos
      # registros compartilhados. Models aninhados sobrescrevem +identity_scope+/+identity_keys+ conforme sua
      # estrutura no pedido.
      module Identifiable
        private

        def find_or_initialize_record
          identity_scope.find_or_initialize_by(identifier: fingerprint, **identity_keys)
        end

        def identity_scope
          model_class
        end

        def identity_keys
          {}
        end
      end
    end
  end
end
