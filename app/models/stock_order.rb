# frozen_string_literal: true

# Stock order model
class StockOrder < VoidableRecord
  has_many :stock_requisitions
  has_many :stock_order_statuses
  validates :voucher_number, uniqueness: true, presence: true

  before_save :strip_voucher_number_whitespace

  def as_json(options = {})
    methods = %i[stock_order_status stock_order_status_trail stock_requisitions]
    super(options.merge(methods:, only: %i[id voucher_number created_date updated_date]))
  end

  def stock_order_status_trail
    StockOrderStatus.where(stock_order_id: id)
  end

  def stock_order_status
    stock_order_statuses&.order(created_date: :desc)&.first&.stock_status&.name
  end

  private

  def strip_voucher_number_whitespace
    self.voucher_number = voucher_number.strip if voucher_number.present?
  end
end
