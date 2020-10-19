module Vtex
  class City < ApplicationRecord
    belongs_to :state
  end
end
