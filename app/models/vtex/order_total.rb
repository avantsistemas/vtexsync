module Vtex
  class OrderTotal < ApplicationRecord
    include Synchronizable
    has_paper_trail

    belongs_to :order
    belongs_to :total

    sync_attributes :value

    remap_attributes value: :value_in_cents

    def value_in_cents=(value_in_cents)
      self.value = value_in_cents ? value_in_cents.to_d / 100 : nil
    end
  end
end
