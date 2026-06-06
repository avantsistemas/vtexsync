module Vtex
  class PaymentSystem < ApplicationRecord
    include Synchronizable

    has_paper_trail

    sync_attributes :paymentSystemName, :group

    remap_attributes paymentSystemName: :name
  end
end
