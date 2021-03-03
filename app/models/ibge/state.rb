module Ibge
  class State < ApplicationRecord
    has_paper_trail

    validates :code, :name, :acronym, presence: true
  end
end
