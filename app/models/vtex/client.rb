module Vtex
  class Client < ApplicationRecord
    include Synchronizable

    sync_attributes :userProfileId, :firstName, :lastName, :email, :documentType, :document, :phone
    remap_attributes userProfileId: :vtex_code
  end
end
