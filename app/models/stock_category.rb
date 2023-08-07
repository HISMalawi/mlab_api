class StockCategory < RetirableRecord
  validates :name, uniqueness: true, presence: true
end
