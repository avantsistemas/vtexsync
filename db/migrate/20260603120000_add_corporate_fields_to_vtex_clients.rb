class AddCorporateFieldsToVtexClients < ActiveRecord::Migration[6.1]
  def change
    change_table :vtex_clients, bulk: true do |t|
      t.string :corporate_name, after: :last_name
      t.string :trade_name, after: :corporate_name
      t.string :corporate_document, after: :document
      t.string :state_inscription, after: :corporate_document
      t.string :corporate_phone, after: :phone
      t.boolean :corporate, default: false, null: false, after: :corporate_phone
    end
  end
end
