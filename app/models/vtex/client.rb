module Vtex
  class Client < ApplicationRecord
    include Synchronizable
    has_paper_trail skip: [:email]

    sync_attributes :userProfileId, :firstName, :lastName, :email, :documentType, :document, :phone
    remap_attributes userProfileId: :identifier

    after_sync_attributes :use_document_as_identifier, unless: :identifier?

    private

    def use_document_as_identifier
      self.identifier = document
    end
  end
end
