module Vtex
  class ProductCategory < ApplicationRecord
    has_paper_trail

    belongs_to :product
    belongs_to :category
  end
end
