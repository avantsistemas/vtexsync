module Vtex
  class Address < ApplicationRecord
    include Synchronizable
    has_paper_trail

    belongs_to :city

    sync_attributes :addressId, :addressType, :receiverName, :postalCode, :city, :state, :country,
                    :street, :number, :neighborhood, :complement, :reference, :geoCoordinates

    remap_attributes addressId: :identifier,
                     city: :city_name,
                     state: :state_acronym,
                     country: :country_acronym

    attr_accessor :country_acronym, :state_acronym, :city_name

    after_sync_attributes :define_city, :truncate_complement

    def geo_coordinates=(geo_coordinates)
      self.latitude, self.longitude = geo_coordinates
    end

    private

    def define_city
      country = Country.find_or_create_by! acronym: country_acronym
      state = country.states.find_or_create_by! acronym: state_acronym
      self.city = state.cities.find_or_create_by! name: city_name
    end

    def truncate_complement
      self.complement = complement.truncate(255, omission: '') if complement?
    end
  end
end
