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
          Vtex::Client.find_or_initialize_by identifier: attribute_user_profile_id
        end

        def attribute_user_profile_id
          client_attributes['userProfileId']
        end
      end
    end
  end
end
