class AddResyncFieldsToVtexOrders < ActiveRecord::Migration[6.0]
  def change
    change_table :vtex_orders, bulk: true do |t|
      t.datetime :resync_requested_at
      t.string :resync_reason
      t.index :resync_requested_at
    end
  end
end
