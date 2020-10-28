module Vtex
  class Brand < ApplicationRecord
    include Synchronizable
    has_paper_trail

    sync_attributes :brandId, :brandName

    remap_attributes brandId: :identifier,
                     brandName: :name
  end
end
