class CreateVtexCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_categories do |t|
      t.string :identifier
      t.string :name

      t.timestamps

      t.index :identifier, unique: true
    end
  end
end
