class CreateVtexOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_orders do |t|
      t.string :vtex_code
      t.integer :sequence
      t.string :status
      t.string :status_description
      t.decimal :value, precision: 8, scale: 2
      t.datetime :creation_date
      t.datetime :last_change

      t.timestamps
    end
  end
end
