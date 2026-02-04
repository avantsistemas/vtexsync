module Vtex
  class Order < ApplicationRecord
    include Synchronizable
    include NotifyPostAffiliatePro

    has_paper_trail

    belongs_to :client
    belongs_to :address

    has_one :campaign, dependent: :destroy

    has_many :totals, class_name: 'Vtex::OrderTotal', dependent: :restrict_with_exception
    has_many :items, class_name: 'Vtex::OrderItem', dependent: :restrict_with_exception
    has_many :transactions, dependent: :restrict_with_exception

    has_many :order_benefits, dependent: :destroy
    has_many :benefits, through: :order_benefits

    has_many :logistics, through: :items

    scope :payment_approved, -> { where(status: 'payment-approved') }

    sync_attributes :orderId, :sellerOrderId, :sequence, :origin, :salesChannel, :hostname,
                    :status, :statusDescription, :allowCancellation, :value, :totalValue,
                    :creationDate, :authorizedDate, :invoicedDate, :lastChange

    remap_attributes orderId: :order_code,
                     sellerOrderId: :seller_order_code,
                     value: :value_in_cents,
                     totalValue: :value_in_cents

    def value_in_cents=(value_in_cents)
      self.value = value_in_cents ? value_in_cents.to_d / 100 : nil
    end

    def shipping_value
      shipping_total = totals.find { |order_total| order_total.total_id == Total.shipping.id }
      shipping_total&.value
    end
  end
end
