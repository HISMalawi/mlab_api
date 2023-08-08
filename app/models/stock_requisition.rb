class StockRequisition < VoidableRecord
  belongs_to :stock
  belongs_to :stock_order
end
