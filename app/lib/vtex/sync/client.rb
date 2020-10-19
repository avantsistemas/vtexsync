module Vtex
  module Sync
    class Client
      include Logger

      def initialize(client_attributes)
        @client_attributes = client_attributes
      end

      def sync
        client = find_or_initialize_vtex_client
        client.sync_attributes(client_attributes)

        log_what_will_be_synced(client)

        client.save! if client.changed?
        client
      end

      private

      attr_reader :client_attributes

      def vtex_user_profile_id
        client_attributes['userProfileId']
      end

      def find_or_initialize_vtex_client
        Vtex::Client.find_or_initialize_by vtex_code: vtex_user_profile_id
      end
    end
  end
end
