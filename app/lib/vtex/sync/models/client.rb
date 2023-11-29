module Vtex
  module Sync
    module Models
      class Client
        def initialize(client_attributes)
          @client_attributes = client_attributes
        end

        def sync
          client = find_or_initialize_vtex_client
          client.sync_attributes(client_attributes)

          Logger.log_what_will_be_synced(client)

          client.save! if client.changed?
          client
        end

        private

        attr_reader :client_attributes

        def find_or_initialize_vtex_client
          Vtex::Client.find_or_initialize_by identifier: client_identifier
        end

        def client_identifier
          # Usávamos sempre `userProfileId` como identificador único do cliente. Porém, recentemente, em pedidos do
          # Mercado Livre, `userProfileId` estava vindo nulo. Para casos assim, usaremos `document` como identificador.
          client_attributes['userProfileId'].presence || client_attributes['document']
        end
      end
    end
  end
end
