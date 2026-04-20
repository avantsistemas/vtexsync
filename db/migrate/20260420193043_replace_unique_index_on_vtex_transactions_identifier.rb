class ReplaceUniqueIndexOnVtexTransactionsIdentifier < ActiveRecord::Migration[6.0]
  # rubocop:disable Rails/BulkChangeTable
  def up
    remove_index :vtex_transactions, :identifier
    add_index :vtex_transactions, :identifier
  end

  def down
    remove_index :vtex_transactions, :identifier
    add_index :vtex_transactions, :identifier, unique: true
  end
  # rubocop:enable Rails/BulkChangeTable
end
