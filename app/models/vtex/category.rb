module Vtex
  class Category < ApplicationRecord
    include Synchronizable
    has_paper_trail

    sync_attributes :id, :name

    remap_attributes id: :identifier
  end
end
