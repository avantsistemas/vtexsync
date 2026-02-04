class AddSalesChannelAndHostnameToVtexOrders < ActiveRecord::Migration[6.0]
  def change
    change_table :vtex_orders, bulk: true do |t|
      t.string :sales_channel, after: :origin
      t.string :hostname, after: :sales_channel
    end
  end
end
