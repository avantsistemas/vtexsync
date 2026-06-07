class CreateVtexOrderResyncRequests < ActiveRecord::Migration[8.0]
  def up
    create_table :vtex_order_resync_requests do |t|
      t.references :order, null: false, foreign_key: { to_table: :vtex_orders }
      t.datetime :requested_at, null: false
      t.string :reason
      t.datetime :completed_at

      t.timestamps
    end
    add_index :vtex_order_resync_requests, :completed_at

    # Preserva as marcações pendentes atuais como requests em aberto.
    execute(<<~SQL.squish)
      INSERT INTO vtex_order_resync_requests
        (order_id, requested_at, reason, created_at, updated_at)
      SELECT id, resync_requested_at, resync_reason, NOW(), NOW()
      FROM vtex_orders
      WHERE resync_requested_at IS NOT NULL
    SQL

    change_table :vtex_orders, bulk: true do |t|
      t.remove :resync_requested_at
      t.remove :resync_reason
    end
  end

  def down
    change_table :vtex_orders, bulk: true do |t|
      t.datetime :resync_requested_at
      t.string :resync_reason
      t.index :resync_requested_at
    end

    # Reconstrói o flag a partir dos requests ainda em aberto.
    execute(<<~SQL.squish)
      UPDATE vtex_orders o
      JOIN vtex_order_resync_requests r ON r.order_id = o.id
      SET o.resync_requested_at = r.requested_at, o.resync_reason = r.reason
      WHERE r.completed_at IS NULL
    SQL

    drop_table :vtex_order_resync_requests
  end
end
