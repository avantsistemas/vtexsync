class CreateVtexConnectorResponses < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_connector_responses do |t|
      t.references :payment, null: false, index: { unique: true }, foreign_key: { to_table: :vtex_payments }
      t.string :tid
      t.string :auth_id
      t.string :nsu
      t.string :network
      t.string :first_digits
      t.string :last_digits
      t.string :acquirer
      t.string :message
      t.string :return_code

      t.timestamps
    end
  end
end
