module Vtex
  class Benefit < ApplicationRecord
    include Synchronizable
    has_paper_trail

    sync_attributes :id, :name, :description, :featured

    remap_attributes id: :identifier
  end
end
