module Vtex
  class State < ApplicationRecord
    belongs_to :country
    has_paper_trail

    has_many :cities, dependent: :restrict_with_exception
  end
end
