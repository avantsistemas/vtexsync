class CreateVtexClients < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_clients do |t|
      t.string :identifier
      t.string :first_name
      t.string :last_name
      t.string :document_type
      t.string :document
      t.string :email
      t.string :phone

      t.timestamps

      t.index :identifier, unique: true
    end
  end
end
