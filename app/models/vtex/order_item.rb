module Vtex
  class OrderItem < ApplicationRecord
    include Synchronizable
    has_paper_trail

    belongs_to :order
    belongs_to :product

    sync_attributes :uniqueId, :productId, :quantity, :price

    remap_attributes uniqueId: :vtex_code,
                     productId: :product_vtex_code,
                     price: :price_in_cents

    def product_vtex_code=(product_vtex_code)
      self.product = Product.find_by! vtex_code: product_vtex_code
    end

    def price_in_cents=(price_in_cents)
      self.price = price_in_cents ? price_in_cents.to_d / 100 : nil
    end
  end
end
