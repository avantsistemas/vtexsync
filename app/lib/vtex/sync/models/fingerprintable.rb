module Vtex
  module Sync
    module Models
      # Padroniza a sincronização de um objeto do JSON de pedidos da VTEX em um registro de catálogo/compartilhado
      # identificado pelo seu +fingerprint+ (ver +Identifiable+): localiza/cria pelo identifier, atribui os demais
      # campos e grava. O fingerprint é a fonte única da identidade — após a atribuição dos demais campos ele é
      # reescrito em +identifier+, sobrepondo qualquer valor que o remap de +sync_attributes+ tenha derivado.
      module Fingerprintable
        include Identifiable

        def sync
          record = find_or_initialize_record
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
