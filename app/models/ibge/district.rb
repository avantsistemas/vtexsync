module Ibge
  class District < ApplicationRecord
    has_paper_trail

    belongs_to :city

    validates :code, :name, presence: true
  end
end
