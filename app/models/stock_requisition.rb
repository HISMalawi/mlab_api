class StockRequisition < RetirableRecord
  belongs_to :stock
  belongs_to :stock_order
end
