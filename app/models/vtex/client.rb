module Vtex
  class Client < ApplicationRecord
    include Synchronizable

    has_paper_trail skip: PAPER_TRAIL_DEFAULT_SKIP + %i[email]

    sync_attributes :firstName, :lastName, :corporateName, :tradeName, :email,
                    :documentType, :document, :corporateDocument, :stateInscription, :phone, :corporatePhone,
                    :isCorporate
    remap_attributes isCorporate: :corporate
  end
end
