# frozen_string_literal: true

# migration class to add reason column to stock transaction
class AddReasonColumnToStockTransaction < ActiveRecord::Migration[7.0]
  def change
    add_column :stock_transactions, :reason, :string
  end
end
