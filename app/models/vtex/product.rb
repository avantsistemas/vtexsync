module Vtex
  class Product < ApplicationRecord
    include Synchronizable
    has_paper_trail

    sync_attributes :id, :name, :refId, :ean, :imageUrl, :detailUrl

    remap_attributes id: :sku_code,
                     refId: :identifier
  end
end
