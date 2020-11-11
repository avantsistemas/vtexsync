class CreateVtexTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_transactions do |t|
      t.references :order, null: false, foreign_key: { to_table: :vtex_orders }
      t.string :identifier
      t.string :merchant_name
      t.boolean :active

      t.timestamps

      t.index :identifier, unique: true
    end
  end
end
