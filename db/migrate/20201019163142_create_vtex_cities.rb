class CreateVtexCities < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_cities do |t|
      t.references :state, null: false, foreign_key: { to_table: :vtex_states }
      t.string :name
      t.integer :ibge_code

      t.timestamps

      t.index %i[name state_id], unique: true
      t.index %i[ibge_code]
    end
  end
end
