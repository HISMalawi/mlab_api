class StockOrder < VoidableRecord
  validates :identifier, uniqueness: true, presence: true
  has_many :stock_requisitions
  has_many :stock_order_statuses
end
