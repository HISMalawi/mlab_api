# frozen_string_literal: true

class AddIndexToUnsyncOrdersForLookup < ActiveRecord::Migration[7.0]
  def up
    # For MySQL 5.6+ with InnoDB, this creates index online without locking
    # Uses ALGORITHM=INPLACE and LOCK=NONE by default
    execute <<-SQL
      ALTER TABLE unsync_orders
      ADD INDEX idx_unsync_orders_voided (test_or_order_id, data_level, voided)
      ALGORITHM=INPLACE, LOCK=NONE
    SQL
  rescue ActiveRecord::StatementInvalid => e
    # Fallback for older MySQL versions that don't support LOCK=NONE
    Rails.logger.warn("Online index creation failed, using standard method: #{e.message}")
    add_index :unsync_orders,
              %i[test_or_order_id data_level voided],
              name: :idx_unsync_orders_voided
  end

  def down
    remove_index :unsync_orders, name: :idx_unsync_orders_voided
  end
end
