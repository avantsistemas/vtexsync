module Vtex
  class OrderBenefit < ApplicationRecord
    has_paper_trail

    belongs_to :order
    belongs_to :benefit
  end
end
