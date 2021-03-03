class CreateIbgeStates < ActiveRecord::Migration[6.0]
  def change
    create_table :ibge_states do |t|
      t.integer :code
      t.string :name
      t.string :acronym

      t.timestamps

      t.index :code, unique: true
      t.index :name, unique: true
      t.index :acronym, unique: true
    end
  end
end
