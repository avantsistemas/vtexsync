class CreateVtexProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_products do |t|
      t.string :vtex_code
      t.string :name
      t.string :sku_name
      t.string :ref_code
      t.string :ean
      t.string :image_url
      t.string :detail_url

      t.timestamps

      t.index :vtex_code, unique: true
    end
  end
end
