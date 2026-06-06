module Vtex
  module Sync
    module Models
      # Padroniza a sincronização de um objeto do JSON de pedidos da VTEX em um registro identificado pelo seu
      # +fingerprint+: a chave-única calculada a partir dos atributos do objeto e gravada na coluna +identifier+.
      #
      # Cada classe que inclui o concern define +model_class+ (a model destino) e +attributes+ (o hash do objeto no
      # JSON), e implementa +fingerprint+ — a regra de unicidade própria daquele objeto. O fingerprint é a fonte única
      # da identidade: localiza/cria o registro e, após a atribuição dos demais campos, é gravado em +identifier+,
      # sobrepondo qualquer valor que o remap de +sync_attributes+ tenha derivado.
      module Fingerprintable
        def sync
          record = model_class.find_or_initialize_by(identifier: fingerprint)
          record.sync_attributes(attributes)
          record.identifier = fingerprint

          Logger.log_what_will_be_synced(record)

          record.save! if record.changed?
          record
        end
      end
    end
  end
end
