class AddCatalogFieldsToVtexProducts < ActiveRecord::Migration[8.0]
  def change
    # Campos vindos do endpoint de catálogo por SKU
    # (GET /api/catalog/pvt/stockkeepingunit/:skuId), que o JSON de pedidos não
    # traz. +creation_date+ nulo marca o produto como ainda não enriquecido.
    change_table :vtex_products, bulk: true do |t|
      # kit/active são nullable de propósito: nil = produto ainda não enriquecido
      # (o enriquecimento roda de forma assíncrona após o cadastro). O marcador
      # de pendência é creation_date IS NULL.
      t.boolean :kit, after: :detail_url # rubocop:disable Rails/ThreeStateBooleanColumn
      t.boolean :active, after: :kit # rubocop:disable Rails/ThreeStateBooleanColumn
      t.datetime :creation_date, after: :active
      t.index :creation_date
    end
  end
end
