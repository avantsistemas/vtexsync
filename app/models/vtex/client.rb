module Vtex
  class Client < ApplicationRecord
    include Synchronizable

    has_paper_trail skip: PAPER_TRAIL_DEFAULT_SKIP + %i[email]

    sync_attributes :userProfileId, :firstName, :lastName, :corporateName, :tradeName, :email,
                    :documentType, :document, :corporateDocument, :stateInscription, :phone, :corporatePhone,
                    :isCorporate
    remap_attributes userProfileId: :identifier, isCorporate: :corporate

    after_sync_attributes :use_document_as_identifier, unless: :identifier?

    private

    def use_document_as_identifier
      self.identifier = document
    end
  end
end
