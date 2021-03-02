class CreateVtexComponents < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_components do |t|
      t.references :order_item, null: false, foreign_key: { to_table: :vtex_order_items }
      t.references :product, null: false, foreign_key: { to_table: :vtex_products }
      t.string :identifier
      t.integer :index
      t.integer :quantity
      t.decimal :price, precision: 8, scale: 2
      t.decimal :selling_price, precision: 8, scale: 2

      t.timestamps

      # Assim como em `vtex_order_items`, utilizamos o índice do componente dentro do ítem como parte da chave-única.
      t.index %i[identifier index order_item_id], unique: true
    end
  end
end
