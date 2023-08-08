class StockLocation < VoidableRecord
  validates :name, uniqueness: true, presence: true
end
