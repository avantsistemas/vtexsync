class CreateVtexOrderTotals < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_order_totals do |t|
      t.references :order, null: false, foreign_key: { to_table: :vtex_orders }
      t.references :total, null: false, foreign_key: { to_table: :vtex_totals }
      t.decimal :value, precision: 8, scale: 2

      t.timestamps

      t.index %i[order_id total_id]
    end
  end
end
