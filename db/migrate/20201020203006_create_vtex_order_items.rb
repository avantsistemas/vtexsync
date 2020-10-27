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

      # Adicionamos `order_id` e `selling_price` como parte da chave única dos itens dos pedidos por conta das
      # repetições de uniqueId que acontece em alguns pedidos. Ex: 1064230768540-01, 1065732673793-01,
      # 1066163355534-01, 1068432854087-01 e 1068192373206-01 (esses dois últimos tendo o uniqueId
      # se repetindo entre dois pedidos diferentes).
      t.index %i[identifier order_id selling_price], unique: true, name: 'vtex_order_items_unique_index'
    end
  end
end
