class AddSellerIdToVtexOrderItems < ActiveRecord::Migration[6.0]
  def change
    add_reference :vtex_order_items, :seller, null: false, foreign_key: { to_table: :vtex_sellers },
                                              after: :product_id
  end
end
