class CreateVtexProductCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_product_categories do |t|
      t.references :product, null: false, foreign_key: { to_table: :vtex_products }
      t.references :category, null: false, foreign_key: { to_table: :vtex_categories }

      t.timestamps

      t.index %i[product_id category_id], unique: true
    end
  end
end
