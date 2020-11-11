module Vtex
  module Sync
    module Models
      class Payment
        module Dependents
          private

          def sync_dependents
            sync_connector_response
          end

          def sync_connector_response
            connector_response_attributes = payment_attributes['connectorResponses']
            ConnectorResponse.new(connector_response_attributes, vtex_payment: vtex_payment).sync
          end
        end
      end
    end
  end
end
