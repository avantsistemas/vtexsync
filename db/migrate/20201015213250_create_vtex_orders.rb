class CreateVtexOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_orders do |t|
      t.string :order_code
      t.string :seller_order_code
      t.integer :sequence
      t.string :origin
      t.string :status
      t.string :status_description
      t.decimal :value, precision: 8, scale: 2
      t.datetime :creation_date
      t.datetime :authorized_date
      t.datetime :invoiced_date
      t.datetime :last_change

      t.timestamps

      t.index :order_code, unique: true
    end
  end
end
