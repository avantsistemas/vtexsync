class CreateVtexCountries < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_countries do |t|
      t.string :acronym

      t.timestamps

      t.index :acronym, unique: true
    end
  end
end
