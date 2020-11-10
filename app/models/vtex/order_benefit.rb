class Vtex::OrderBenefit < ApplicationRecord
  belongs_to :order
  belongs_to :benefit
end
