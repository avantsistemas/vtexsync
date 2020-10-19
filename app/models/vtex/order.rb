module Vtex
  class Order < ApplicationRecord
    include Synchronizable

    belongs_to :client
    belongs_to :shipping_address, class_name: 'Vtex::Address'

    sync_attributes :orderId, :sequence, :origin, :status, :statusDescription, :value, :creationDate, :lastChange
    remap_attributes orderId: :vtex_code, value: :value_in_cents

    def value_in_cents=(value)
      self.value = value ? value.to_d / 100 : nil
    end
  end
end
