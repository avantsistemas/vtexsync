class CreateIbgeCities < ActiveRecord::Migration[6.0]
  def change
    create_table :ibge_cities do |t|
      t.references :state, null: false, foreign_key: { to_table: :ibge_states }
      t.integer :code
      t.string :name

      t.timestamps

      t.index :code, unique: true
      t.index %i[name state_id], unique: true
    end
  end
end
