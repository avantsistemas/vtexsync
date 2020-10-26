class CreateVtexSellers < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_sellers do |t|
      t.string :identifier
      t.string :name
      t.string :logo

      t.timestamps

      t.index :identifier, unique: true
    end
  end
end
