module Vtex
  class Transaction < ApplicationRecord
    include Synchronizable
    has_paper_trail

    belongs_to :order

    sync_attributes :transactionId, :merchantName, :isActive

    remap_attributes transactionId: :identifier,
                     isActive: :active
  end
end
