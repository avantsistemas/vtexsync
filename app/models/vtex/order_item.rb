module Vtex
  class OrderItem < ApplicationRecord
    include Synchronizable
    has_paper_trail

    belongs_to :order
    belongs_to :product
    belongs_to :seller

    sync_attributes :uniqueId, :refId, :seller, :quantity, :price, :sellingPrice

    remap_attributes uniqueId: :identifier,
                     refId: :product_identifier,
                     seller: :seller_identifier,
                     price: :price_in_cents,
                     sellingPrice: :selling_price_in_cents

    def product_identifier=(product_identifier)
      self.product = Product.find_by! identifier: product_identifier
    end

    def seller_identifier=(seller_identifier)
      self.seller = Seller.find_by! identifier: seller_identifier
    end

    def price_in_cents=(price_in_cents)
      self.price = price_in_cents ? price_in_cents.to_d / 100 : nil
    end

    def selling_price_in_cents=(selling_price_in_cents)
      self.selling_price = selling_price_in_cents ? selling_price_in_cents.to_d / 100 : nil
    end
  end
end
