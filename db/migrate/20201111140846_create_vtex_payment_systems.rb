class CreateVtexPaymentSystems < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_payment_systems do |t|
      t.string :identifier
      t.string :name
      t.string :group

      t.timestamps

      t.index :identifier, unique: true
    end
  end
end
