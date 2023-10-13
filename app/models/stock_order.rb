# frozen_string_literal: true

# Stock order model
class StockOrder < VoidableRecord
  has_many :stock_requisitions
  has_many :stock_order_statuses
  has_many :stock_pharmacy_approver_and_issuers
  validates :voucher_number, uniqueness: true, presence: true

  before_save :strip_voucher_number_whitespace

  def as_json(options = {})
    methods = %i[stock_order_status stock_order_status_trail stock_requisitions stock_pharmacy_approver_and_issuers]
    super(options.merge(methods:, only: %i[id voucher_number created_date updated_date]))
  end

  def stock_order_status_trail
    StockOrderStatus.where(stock_order_id: id)
  end

  def stock_order_status
    stock_order_statuses&.order(created_date: :desc)&.first&.stock_status&.name
  end

  def self.search(voucher_number)
    where("voucher_number LIKE '%#{voucher_number}%'").order(created_date: :desc)
  end

  def self.filter_by_stock_order_status(status_id)
    stock_orders = StockOrder.joins(:stock_order_statuses).where('stock_order_statuses.created_date = (
      SELECT MAX(sos.created_date) FROM stock_order_statuses AS sos
      WHERE sos.stock_order_id = stock_orders.id
    )')
    stock_orders = stock_orders.where("stock_order_statuses.stock_status_id = #{status_id}") if status_id.present?
    stock_orders
  end

  private

  def strip_voucher_number_whitespace
    self.voucher_number = voucher_number.strip if voucher_number.present?
  end
end
