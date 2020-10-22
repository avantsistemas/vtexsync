module Vtex
  class Country < ApplicationRecord
    has_paper_trail

    has_many :states, dependent: :restrict_with_exception
  end
end
