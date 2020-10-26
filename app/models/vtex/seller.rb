module Vtex
  class Seller < ApplicationRecord
    include Synchronizable
    has_paper_trail

    sync_attributes :id, :name, :logo

    remap_attributes id: :identifier
  end
end
