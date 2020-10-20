class CreateVtexOrderItems < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_order_items do |t|
      t.references :order, null: false, foreign_key: { to_table: :vtex_orders }
      t.references :product, null: false, foreign_key: { to_table: :vtex_products }
      t.string :vtex_code
      t.integer :quantity
      t.decimal :price, precision: 8, scale: 2

      t.timestamps

      t.index :vtex_code, unique: true
    end
  end
end
