class CreateVtexOrderBenefits < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_order_benefits do |t|
      t.references :order, null: false, foreign_key: { to_table: :vtex_orders }
      t.references :benefit, null: false, foreign_key: { to_table: :vtex_benefits }

      t.timestamps

      t.index %i[order_id benefit_id], unique: true
    end
  end
end
