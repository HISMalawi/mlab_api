class StockOrderStatus < ApplicationRecord
  belongs_to :stock_order
  belongs_to :status
  def status_name
    status.name if status
  end
end
