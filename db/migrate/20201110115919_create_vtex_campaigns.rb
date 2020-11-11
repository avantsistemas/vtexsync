class CreateVtexCampaigns < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_campaigns do |t|
      t.references :order, null: false, index: { unique: true }, foreign_key: { to_table: :vtex_orders }
      t.string :utm_source
      t.string :utm_partner
      t.string :utm_medium
      t.string :utm_campaign
      t.string :coupon

      t.timestamps
    end
  end
end
