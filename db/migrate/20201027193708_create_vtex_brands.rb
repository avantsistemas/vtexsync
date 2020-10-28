class CreateVtexBrands < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_brands do |t|
      t.string :name
      t.string :identifier

      t.timestamps

      t.index :identifier, unique: true
    end
  end
end
