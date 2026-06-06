module Vtex
  class Category < ApplicationRecord
    include Synchronizable

    has_paper_trail

    sync_attributes :name
  end
end
