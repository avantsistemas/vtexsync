module Vtex
  module Sync
    class Client
      delegate :logger, to: Rails

      def initialize(client_attributes)
        @client_attributes = client_attributes
      end

      def sync
        logger.tagged(vtex_user_profile_id) do
          find_or_initialize_vtex_client.tap do |client|
            client.sync_attributes(client_attributes)
            log_what_will_be_done(client)
            client.save! if client.changed?
          end
        end
      end

      private

      attr_reader :client_attributes

      def vtex_user_profile_id
        client_attributes['userProfileId']
      end

      def find_or_initialize_vtex_client
        Vtex::Client.find_or_initialize_by vtex_code: vtex_user_profile_id
      end

      def log_what_will_be_done(vtex_client)
        if vtex_client.new_record?
          attributes = vtex_client.attributes.except('id', 'created_at', 'updated_at')
          logger.info "Um novo cliente será cadastrado: #{attributes.as_json}"
        elsif vtex_client.changed?
          logger.info "O cliente será atualizado: #{vtex_client.changes.as_json}"
        else
          logger.debug 'O cliente já está sincronizado'
        end
      end
    end
  end
end
