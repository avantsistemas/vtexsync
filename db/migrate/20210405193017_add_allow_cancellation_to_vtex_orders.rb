class AddAllowCancellationToVtexOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :vtex_orders, :allow_cancellation, :boolean, after: :status_description
    reversible do |dir|
      dir.up { execute 'UPDATE vtex_orders SET allow_cancellation = FALSE' }
    end
  end
end
