module Vtex
  class PaymentSystem < ApplicationRecord
    include Synchronizable
    has_paper_trail

    sync_attributes :paymentSystem, :paymentSystemName, :group

    remap_attributes paymentSystem: :identifier,
                     paymentSystemName: :name
  end
end
