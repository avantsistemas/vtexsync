module Vtex
  class ConnectorResponse < ApplicationRecord
    include Synchronizable
    has_paper_trail

    belongs_to :payment

    sync_attributes :tid, :authId, :nsu, :network, :first_digits, :last_digits, :acquirer, :message, :return_code
  end
end
