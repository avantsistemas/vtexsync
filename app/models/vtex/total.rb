module Vtex
  class Total < ApplicationRecord
    include Synchronizable
    has_paper_trail

    sync_attributes :id, :name

    remap_attributes id: :identifier

    def self.shipping
      @shipping ||= find_by identifier: 'Shipping'
    end
  end
end
