module Vtex
  class Order < ApplicationRecord
    include Synchronizable

    belongs_to :client
    belongs_to :shipping_address, class_name: 'Vtex::Address'

    has_many :items, class_name: 'Vtex::OrderItem', dependent: :restrict_with_exception

    sync_attributes :orderId, :sequence, :origin, :status, :statusDescription, :value, :creationDate, :lastChange

    remap_attributes orderId: :vtex_code,
                     value: :value_in_cents

    def value_in_cents=(value_in_cents)
      self.value = value_in_cents ? value_in_cents.to_d / 100 : nil
    end
  end
end
