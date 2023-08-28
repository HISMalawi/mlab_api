# frozen_string_literal: true

# Migration for adding remaining balance columns to the stock transactions table
class AddRemaingBalanceToStockTransaction < ActiveRecord::Migration[7.0]
  def change
    add_column :stock_transactions, :remaining_balance, :integer
  end
end
