module Vtex
  class Product < ApplicationRecord
    include Synchronizable
    has_paper_trail

    sync_attributes :Id, :Name, :SkuName, :RefId, :Ean, :ImageUrl, :DetailUrl

    remap_attributes Id: :sku_code,
                     RefId: :identifier
  end
end
