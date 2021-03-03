module Vtex
  class Logistic < ApplicationRecord
    include Synchronizable
    has_paper_trail

    belongs_to :order_item
    belongs_to :sla

    sync_attributes :deliveryCompany, :shippingEstimate, :shippingEstimateDate,
                    :price, :listPrice, :sellingPrice, :transitTime

    remap_attributes price: :price_in_cents,
                     listPrice: :list_price_in_cents,
                     sellingPrice: :selling_price_in_cents

    def price_in_cents=(price_in_cents)
      self.price = price_in_cents ? price_in_cents.to_d / 100 : nil
    end

    def list_price_in_cents=(list_price_in_cents)
      self.list_price = list_price_in_cents ? list_price_in_cents.to_d / 100 : nil
    end

    def selling_price_in_cents=(selling_price_in_cents)
      self.selling_price = selling_price_in_cents ? selling_price_in_cents.to_d / 100 : nil
    end
  end
end
