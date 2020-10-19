class AddShippingAddressIdToVtexOrders < ActiveRecord::Migration[6.0]
  def change
    add_reference :vtex_orders, :shipping_address, null: false, foreign_key: { to_table: :vtex_addresses },
                                                   after: :client_id
  end
end
