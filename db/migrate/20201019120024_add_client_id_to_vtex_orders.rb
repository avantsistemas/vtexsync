class AddClientIdToVtexOrders < ActiveRecord::Migration[6.0]
  def change
    add_reference :vtex_orders, :client, null: false, foreign_key: { to_table: :vtex_clients }, after: :id
  end
end
