module Vtex
  module Sync
    class Address
      include Logger

      def initialize(addresss_attributes)
        @address_attributes = addresss_attributes
      end

      def sync(save: true)
        address = find_or_initialize_vtex_address
        address.sync_attributes(address_attributes)

        log_what_will_be_synced(address)

        address.save! if save && address.changed?
        address
      end

      private

      attr_reader :address_attributes

      def find_or_initialize_vtex_address
        Vtex::Address.find_or_initialize_by vtex_code: vtex_address_id
      end

      def vtex_address_id
        address_attributes['addressId']
      end
    end
  end
end
