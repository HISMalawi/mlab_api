# frozen_string_literal: true

# stock order status model
class StockOrderStatus < VoidableRecord
  belongs_to :stock_order
  belongs_to :stock_status
end
