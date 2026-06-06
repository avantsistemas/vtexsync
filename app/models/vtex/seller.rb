module Vtex
  class Seller < ApplicationRecord
    include Synchronizable

    has_secure_token
    has_paper_trail

    has_many :order_items, dependent: :restrict_with_exception
    has_many :orders, -> { distinct }, through: :order_items

    sync_attributes :name, :logo
  end
end
