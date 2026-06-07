module Vtex
  class Product < ApplicationRecord
    include Synchronizable

    has_paper_trail

    belongs_to :brand, optional: true

    has_many :product_categories, dependent: :destroy
    has_many :categories, through: :product_categories

    # Produtos ainda sem os atributos de catálogo (kit, ativo, data de criação),
    # que vêm de um endpoint à parte e são preenchidos pelo enriquecimento.
    scope :pending_enrichment, -> { where(creation_date: nil) }

    # Produto recém-criado pelo sync de pedido nasce sem os dados de catálogo.
    # Enfileiramos o enriquecimento após o commit da transação do pedido, fora
    # dela, para não segurar a transação durante a chamada de rede.
    after_create_commit :enqueue_enrichment

    sync_attributes :id, :name, :refId, :ean, :imageUrl, :detailUrl

    remap_attributes id: :sku_code,
                     refId: :identifier

    after_sync_attributes :remove_parameters_from_image_url

    private

    def enqueue_enrichment
      Vtex::Sync::ProductEnrichmentJob.perform_later(id)
    end

    def remove_parameters_from_image_url
      self.image_url = image_url[0, image_url.index('?')] if image_url? && image_url.include?('?')
    end
  end
end
