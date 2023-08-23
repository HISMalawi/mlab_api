# frozen_string_literal: true

# stock requisition model
class StockRequisition < VoidableRecord
  belongs_to :stock_item
  belongs_to :stock_order
  has_many :requisition_statuses

  after_create :create_stock_status

  def as_json(options = {})
    methods = %i[item requisition_status_trail requisition_status]
    super(options.merge(methods:, only: %i[id stock_order_id quantity_requested quantity_issued quantity_collected created_date updated_date]))
  end

  def item
    {
      id: stock_item.id,
      name: stock_item.name,
      description: stock_item.description,
      measurement_unit: StockUnit.where(id: stock_item.measurement_unit).first&.name,
      quantity_unit: stock_item.quantity_unit,
      stock_category: stock_item.stock_category.name
    }
  end

  def requisition_status_trail
    RequisitionStatus.where(stock_requisition_id: id)
  end

  def requisition_status
    requisition_statuses&.order(created_date: :desc)&.first&.stock_status&.name
  end

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
