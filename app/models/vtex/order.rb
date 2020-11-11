module Vtex
  class Order < ApplicationRecord
    include Synchronizable
    has_paper_trail

    belongs_to :client
    belongs_to :shipping_address, class_name: 'Vtex::Address'

    has_one :campaign, dependent: :destroy

    has_many :totals, class_name: 'Vtex::OrderTotal', dependent: :restrict_with_exception
    has_many :items, class_name: 'Vtex::OrderItem', dependent: :restrict_with_exception
    has_many :transactions, dependent: :restrict_with_exception

    has_many :order_benefits, dependent: :destroy
    has_many :benefits, through: :order_benefits

    sync_attributes :orderId, :sequence, :origin, :status, :statusDescription,
                    :value, :totalValue, :creationDate, :authorizedDate,
                    :invoicedDate, :lastChange

    remap_attributes orderId: :identifier,
                     value: :value_in_cents,
                     totalValue: :value_in_cents

    def value_in_cents=(value_in_cents)
      self.value = value_in_cents ? value_in_cents.to_d / 100 : nil
    end
  end
end
