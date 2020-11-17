module Vtex
  class Client < ApplicationRecord
    include Synchronizable
    has_paper_trail skip: [:email]

    sync_attributes :userProfileId, :firstName, :lastName, :email, :documentType, :document, :phone
    remap_attributes userProfileId: :identifier
  end
end
