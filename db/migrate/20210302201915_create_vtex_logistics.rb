class CreateVtexLogistics < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_logistics do |t|
      t.references :order_item, null: false, index: { unique: true }, foreign_key: { to_table: :vtex_order_items }
      t.references :sla, null: false, foreign_key: { to_table: :vtex_slas }
      t.string :delivery_company
      t.string :shipping_estimate
      t.datetime :shipping_estimate_date
      t.decimal :price, precision: 8, scale: 2
      t.decimal :list_price, precision: 8, scale: 2
      t.decimal :selling_price, precision: 8, scale: 2
      t.string :transit_time

      t.timestamps
    end
  end
end
