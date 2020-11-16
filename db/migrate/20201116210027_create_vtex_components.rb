class CreateVtexComponents < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_components do |t|
      t.references :order_item, null: false, foreign_key: { to_table: :vtex_order_items }
      t.references :product, null: false, foreign_key: { to_table: :vtex_products }
      t.string :identifier
      t.integer :quantity
      t.decimal :price, precision: 8, scale: 2
      t.decimal :selling_price, precision: 8, scale: 2

      t.timestamps

      # Adicionamos `order_item_id`, `quantity` e `selling_price` como parte da chave única dos componentes por
      # conta das repetições de uniqueId que acontece em alguns pedidos.
      t.index %i[identifier order_item_id quantity selling_price], unique: true, name: 'vtex_components_unique_index'
    end
  end
end
