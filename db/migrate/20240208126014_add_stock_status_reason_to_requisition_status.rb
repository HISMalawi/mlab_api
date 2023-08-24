# frozen_string_literal: true

# migration to add stock status reason to requisition status
class AddStockStatusReasonToRequisitionStatus < ActiveRecord::Migration[7.0]
  def change
    add_column :requisition_statuses, :stock_status_reason, :string
  end
end
