module Ibge
  class State < ApplicationRecord
    validates :code, :name, :acronym, presence: true
  end
end
