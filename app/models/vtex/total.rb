module Vtex
  class Total < ApplicationRecord
    include Synchronizable

    has_paper_trail

    sync_attributes :id, :name

    remap_attributes id: :identifier

    def self.shipping_id
      @shipping_id ||= find_by!(identifier: 'Shipping').id
    end
  end
end
