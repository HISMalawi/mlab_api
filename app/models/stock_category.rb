class StockCategory < VoidableRecord
  validates :name, uniqueness: true, presence: true
end
