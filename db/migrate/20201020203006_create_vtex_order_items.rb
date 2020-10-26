class CreateVtexOrderItems < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_order_items do |t|
      t.references :order, null: false, foreign_key: { to_table: :vtex_orders }
      t.references :product, null: false, foreign_key: { to_table: :vtex_products }
      t.string :identifier
      t.integer :quantity
      t.decimal :price, precision: 8, scale: 2
      t.decimal :selling_price, precision: 8, scale: 2

      t.timestamps

      # Adicionamos `quantity` como parte da chave única dos itens dos pedidos por conta das repetições de
      # uniqueId que acontece em alguns pedidos. Ex: 1064230768540-01, 1065732673793-01 e 1066163355534-01.
      t.index %i[identifier quantity], unique: true
    end
  end
end
