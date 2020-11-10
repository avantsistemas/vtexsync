class CreateVtexBenefits < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_benefits do |t|
      t.string :identifier
      t.string :name
      t.string :description
      t.boolean :featured

      t.timestamps

      t.index :identifier, unique: true
    end
  end
end
