class CreateVtexStates < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_states do |t|
      t.references :country, null: false, foreign_key: { to_table: :vtex_countries }
      t.string :acronym

      t.timestamps

      t.index %i[acronym country_id], unique: true
    end
  end
end
