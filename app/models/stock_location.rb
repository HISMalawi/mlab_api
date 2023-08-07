class StockLocation < RetirableRecord
  validates :name, uniqueness: true, presence: true
end
