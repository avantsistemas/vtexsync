class CreateVtexAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_addresses do |t|
      t.references :city, null: false, foreign_key: { to_table: :vtex_cities }
      t.string :identifier
      t.string :address_type
      t.string :receiver_name
      t.string :postal_code
      t.string :street
      t.string :number
      t.string :neighborhood
      t.string :complement
      t.string :reference
      # https://github.com/rails/rails/issues/14135
      t.float :latitude, limit: 53
      t.float :longitude, limit: 53

      t.timestamps

      t.index :identifier, unique: true
    end
  end
end
