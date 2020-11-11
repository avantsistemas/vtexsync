module Vtex
  module Sync
    module Models
      class ConnectorResponse
        def initialize(connector_response_attributes, vtex_payment:)
          @connector_response_attributes = connector_response_attributes
          @vtex_payment = vtex_payment
        end

        def sync
          connector_response = find_or_initialize_vtex_connector_response
          connector_response.sync_attributes(connector_response_attributes)

          Logger.log_what_will_be_synced(connector_response)

          connector_response.save! if vtex_payment.persisted? && connector_response.changed?
          connector_response
        end

        private

        attr_reader :connector_response_attributes, :vtex_payment

        def find_or_initialize_vtex_connector_response
          vtex_payment.connector_response || vtex_payment.build_connector_response
        end
      end
    end
  end
end
