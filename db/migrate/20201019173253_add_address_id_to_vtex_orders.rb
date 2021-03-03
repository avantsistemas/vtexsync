class AddAddressIdToVtexOrders < ActiveRecord::Migration[6.0]
  def change
    add_reference :vtex_orders, :address, null: false, foreign_key: { to_table: :vtex_addresses }, after: :client_id
  end
end
