class AddTokenToVtexSellers < ActiveRecord::Migration[6.0]
  def change
    change_table :vtex_sellers, bulk: true do |t|
      t.string :token, after: :identifier
      t.index :token, unique: true
    end
  end
end
