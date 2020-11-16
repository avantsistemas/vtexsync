class AddBrandIdToVtexProducts < ActiveRecord::Migration[6.0]
  def change
    add_reference :vtex_products, :brand, foreign_key: { to_table: :vtex_brands }, after: :id
  end
end
