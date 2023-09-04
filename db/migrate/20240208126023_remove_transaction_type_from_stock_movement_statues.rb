# frozen_string_literal: true

# stock movement statuses migration
class RemoveTransactionTypeFromStockMovementStatues < ActiveRecord::Migration[7.0]
  def change
    remove_column :stock_movement_statues, :stock_transaction_type_id, :integer
  end
end
