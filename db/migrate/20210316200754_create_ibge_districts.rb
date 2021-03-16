class CreateIbgeDistricts < ActiveRecord::Migration[6.0]
  def change
    create_table :ibge_districts do |t|
      t.references :city, null: false, foreign_key: { to_table: :ibge_cities }
      t.string :code
      t.string :name

      t.timestamps

      t.index :code, unique: true
      t.index %i[name city_id], unique: true
    end
  end
end
