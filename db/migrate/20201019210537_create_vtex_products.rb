class CreateVtexProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_products do |t|
      t.string :name
      t.string :sku_name
      t.string :identifier
      t.string :ean
      t.string :image_url
      t.string :detail_url

      t.timestamps

      t.index :identifier, unique: true
    end
  end
end
