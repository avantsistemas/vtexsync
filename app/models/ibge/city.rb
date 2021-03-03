module Ibge
  class City < ApplicationRecord
    has_paper_trail

    belongs_to :state

    validates :code, :name, presence: true
  end
end
