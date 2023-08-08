class StockOrder < VoidableRecord
  validates :identifier, uniqueness: true, presence: true
  has_many :stock_requisitions
end
