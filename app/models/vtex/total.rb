module Vtex
  class Total < ApplicationRecord
    include Synchronizable

    has_paper_trail

    sync_attributes :name

    def self.shipping_id
      @shipping_id ||= find_by!(identifier: 'Shipping').id
    end
  end
end
