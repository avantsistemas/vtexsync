module Vtex
  class City < ApplicationRecord
    has_paper_trail

    belongs_to :state
  end
end
