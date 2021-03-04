module Vtex
  class City < ApplicationRecord
    has_paper_trail

    belongs_to :state

    before_create :define_ibge_code

    private

    def define_ibge_code
      ibge_city = find_corresponding_ibge_city
      self.ibge_code = ibge_city.code
    end

    def find_corresponding_ibge_city
      ibge_state = Ibge::State.find_by acronym: state.acronym
      ibge_city = Ibge::City.find_by name: name, state: ibge_state
      ibge_city || raise("Cidade #{name} / #{state.acronym} sem código IBGE")
    end
  end
end
