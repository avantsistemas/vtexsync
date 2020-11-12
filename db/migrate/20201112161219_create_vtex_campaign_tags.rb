class CreateVtexCampaignTags < ActiveRecord::Migration[6.0]
  def change
    create_table :vtex_campaign_tags do |t|
      t.references :campaign, null: false, foreign_key: { to_table: :vtex_campaigns }
      t.references :marketing_tag, null: false, foreign_key: { to_table: :vtex_marketing_tags }

      t.timestamps

      t.index %i[campaign_id marketing_tag_id], unique: true
    end
  end
end
