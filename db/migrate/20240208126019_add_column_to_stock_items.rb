# frozen_string_literal: true

# Add columns migration
class AddColumnToStockItems < ActiveRecord::Migration[7.0]
  def change
    add_column :stock_items, :strength, :string
    add_column :stocks, :minimum_order_level, :integer
  end
end
