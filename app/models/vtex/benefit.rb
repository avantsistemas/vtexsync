module Vtex
  class Benefit < ApplicationRecord
    include Synchronizable

    has_paper_trail

    sync_attributes :name, :description, :featured
  end
end
