module Vtex
  class State < ApplicationRecord
    has_paper_trail

    belongs_to :country

    has_many :cities, dependent: :restrict_with_exception
  end
end
