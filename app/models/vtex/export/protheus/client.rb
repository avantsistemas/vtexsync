module Vtex
  module Export
    module Protheus
      class Client < Exportable
        def initialize(client, address)
          @client = client
          @address = address
        end

        def full_name
          [@client.first_name, @client.last_name].compact.join(' ')
        end

        def address
          [@address.street, @address.number].compact.join(', ')
        end

        def neighborhood
          @address.neighborhood
        end

        def complement
          @address.complement
        end

        def postal_code
          @address.postal_code.gsub(/\W/, '')
        end

        def phone_area_code
          @client.phone.start_with?('+') ? @client.phone[3..4] : @client.phone[0..1]
        end

        def phone_without_area_code
          @client.phone.start_with?('+') ? @client.phone[5..] : @client.phone[2..]
        end

        def email
          @client.email
        end

        def state_acronym
          @address.city.state.acronym
        end

        def document
          @client.document
        end

        def city_ibge_code
          @address.city.ibge_code
        end

        private

        def data_array
          [
            full_name,
            address,
            neighborhood,
            complement,
            postal_code,
            phone_area_code,
            phone_without_area_code,
            phone_without_area_code,
            email,
            state_acronym,
            document,
            city_ibge_code
          ]
        end
      end
    end
  end
end
