# frozen_string_literal: true

# stock requisition model
class StockRequisition < VoidableRecord
  belongs_to :stock_item
  belongs_to :stock_order

  after_create :create_stock_status

  private

  def create_stock_status
    status_id = StockStatus.find_by_name('Draft').id
    StockOrderStatus.create!(
      stock_order_id:,
      stock_status_id: status_id
    )
    RequisitionStatus.create!(
      stock_status_id: status_id,
      stock_requisition_id: id
    )
  end
end
