module Vtex
  class Product < ApplicationRecord
    include Synchronizable

    sync_attributes :Id, :Name, :SkuName, :RefId, :Ean, :ImageUrl, :DetailUrl
    remap_attributes Id: :vtex_code, RefId: :ref_code
  end
end
