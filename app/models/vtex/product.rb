module Vtex
  class Product < ApplicationRecord
    include Synchronizable
    has_paper_trail

    sync_attributes :Name, :SkuName, :RefId, :Ean, :ImageUrl, :DetailUrl

    remap_attributes RefId: :identifier
  end
end
