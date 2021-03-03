module Vtex
  class Product < ApplicationRecord
    include Synchronizable
    has_paper_trail

    belongs_to :brand, optional: true

    has_many :product_categories, dependent: :destroy
    has_many :categories, through: :product_categories

    sync_attributes :id, :name, :refId, :ean, :imageUrl, :detailUrl

    remap_attributes id: :sku_code,
                     refId: :identifier

    after_sync_attributes :remove_parameters_from_image_url

    private

    def remove_parameters_from_image_url
      self.image_url = image_url[0, image_url.index('?')] if image_url? && image_url.include?('?')
    end
  end
end
