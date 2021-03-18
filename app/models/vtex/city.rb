module Vtex
  class City < ApplicationRecord
    has_paper_trail

    belongs_to :state

    before_create :define_ibge_code

    private

    def define_ibge_code
      ibge_state = Ibge::State.find_by acronym: state.acronym

      self.ibge_code = get_ibge_code_from_city(ibge_state) ||
                       get_ibge_code_from_district(ibge_state)

      logger.warn "Cidade #{name} / #{state.acronym} sem código IBGE" unless ibge_code?
    end

    def get_ibge_code_from_city(ibge_state)
      ibge_city = Ibge::City.find_by name: name, state: ibge_state
      ibge_city&.code
    end

    def get_ibge_code_from_district(ibge_state)
      ibge_district = Ibge::District.joins(:city).find_by name: name, ibge_cities: { state_id: ibge_state }
      ibge_district ||= try_find_district_parsing_its_name(ibge_state)
      ibge_district&.city&.code
    end

    # noinspection RegExpRedundantNestedCharacterClass
    def try_find_district_parsing_its_name(ibge_state)
      # extrai o nome da cidade e do distrito de um
      # nome como no padrão "Juiz de Fora (Torreões)"
      match_data = name.match(/([[[:alpha:]]\s]+)\s+\(([[[:alpha:]]\s]+)\)/)
      return unless match_data

      city_name, district_name = match_data.captures
      return unless city_name.present? && district_name.present?

      Ibge::District.joins(:city).find_by name: district_name, ibge_cities: { name: city_name,
                                                                              state_id: ibge_state }
    end
  end
end
