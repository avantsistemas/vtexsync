module Vtex
  class Component < ApplicationRecord
    include Synchronizable
    has_paper_trail

    belongs_to :order_item
    belongs_to :product

    sync_attributes :uniqueId, :refId, :quantity, :price, :sellingPrice

    remap_attributes uniqueId: :identifier,
                     refId: :product_identifier,
                     price: :price_in_cents,
                     sellingPrice: :selling_price_in_cents

    def product_identifier=(product_identifier)
      self.product = Product.find_by! identifier: product_identifier
    end

    def price_in_cents=(price_in_cents)
      self.price = price_in_cents ? price_in_cents.to_d / 100 : nil
    end

    def selling_price_in_cents=(selling_price_in_cents)
      self.selling_price = selling_price_in_cents ? selling_price_in_cents.to_d / 100 : nil
    end

    def kit?
      false
    end

    def gift?
      selling_price.zero?
    end

    def discount
      price - selling_price
    end
  end
end
