module Vtex
  class Country < ApplicationRecord
    has_many :states, dependent: :restrict_with_exception
  end
end
