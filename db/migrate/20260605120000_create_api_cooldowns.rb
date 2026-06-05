class CreateApiCooldowns < ActiveRecord::Migration[6.1]
  def change
    create_table :api_cooldowns do |t|
      t.string :name, null: false
      t.datetime :cooled_down_until

      t.timestamps
    end

    add_index :api_cooldowns, :name, unique: true
  end
end
