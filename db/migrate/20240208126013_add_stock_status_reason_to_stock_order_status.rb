# frozen_string_literal: true

# Add stock status reason to stock order status migration
class AddStockStatusReasonToStockOrderStatus < ActiveRecord::Migration[7.0]
  def change
    add_column :stock_order_statuses, :stock_status_reason, :string
  end
end
