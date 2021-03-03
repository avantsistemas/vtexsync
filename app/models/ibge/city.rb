module Ibge
  class City < ApplicationRecord
    belongs_to :state

    validates :code, :name, presence: true
  end
end
