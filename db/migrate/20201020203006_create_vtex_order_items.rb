class CreateVtexOrderItems < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_order_items do |t|
      t.references :order, null: false, foreign_key: { to_table: :vtex_orders }
      t.references :product, null: false, foreign_key: { to_table: :vtex_products }
      t.string :identifier
      t.integer :index
      t.integer :quantity
      t.decimal :price, precision: 8, scale: 2
      t.decimal :selling_price, precision: 8, scale: 2

      t.timestamps

      # Por conta da repetição de "uniqueId" nos itens do JSON de pedidos da VTEX, incluímos a propriedade "index" que
      # nada mais é que o índice do item dentro da lista de itens do JSON. Usamos esse índice como parte da chave-única.
      t.index %i[identifier index order_id], unique: true
    end
  end
end
