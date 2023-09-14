# frozen_string_literal: true

# migration to add balances columns to stock transaction
class AddBalancesColumnsToStockTransaction < ActiveRecord::Migration[7.0]
  def change
    add_column :stock_transactions, :overall_stock_balance_after_transaction, :integer, default: 0
    add_column :stock_transactions, :overall_stock_balance_before_transaction, :integer, default: 0
  end
end
