class CreateVtexPayments < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_payments do |t|
      t.references :transaction, null: false, foreign_key: { to_table: :vtex_transactions }
      t.references :payment_system, null: false, foreign_key: { to_table: :vtex_payment_systems }
      t.string :identifier
      t.decimal :value, precision: 8, scale: 2
      t.integer :installments

      t.timestamps

      t.index :identifier, unique: true
    end
  end
end
