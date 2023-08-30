# frozen_string_literal: true

# migration to add not_collected_reason and quantity_not_collected columns to stock_requisitions table 
class AddNotCollectedReasonColumnToStockRequistions < ActiveRecord::Migration[7.0]
  def change
    add_column :stock_requisitions, :not_collected_reason, :string
    add_column :stock_requisitions, :quantity_not_collected, :integer
  end
end
