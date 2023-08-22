# frozen_string_literal: true

# Stock order model
class StockOrder < VoidableRecord
  has_many :stock_requisitions
  has_many :stock_order_statuses
  validates :voucher_number, uniqueness: true, presence: true

  before_save :strip_voucher_number_whitespace

  # def statuses
  #   stock_order_statuses.map do |status|
  #     { id: status.status_id, name: status.status_name }
  #   end
  # end

  # def requisitions
  #   stock_requisitions.map do |requisition|
  #     requisition
  #   end
  # end

  private

  def strip_voucher_number_whitespace
    self.voucher_number = voucher_number.strip if voucher_number.present?
  end
end
