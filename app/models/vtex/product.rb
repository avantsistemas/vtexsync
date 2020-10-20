module Vtex
  class Product < ApplicationRecord
    include Synchronizable

    sync_attributes :ProductId, :Name, :SkuName, :RefId, :Ean, :ImageUrl, :DetailUrl

    remap_attributes ProductId: :vtex_code,
                     RefId: :ref_code
  end
end
