class StockSupplier < VoidableRecord
  validates :name, uniqueness: true, presence: true
end
