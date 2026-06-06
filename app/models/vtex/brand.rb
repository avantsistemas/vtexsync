module Vtex
  class Brand < ApplicationRecord
    include Synchronizable

    has_paper_trail

    sync_attributes :brandName

    remap_attributes brandName: :name
  end
end
