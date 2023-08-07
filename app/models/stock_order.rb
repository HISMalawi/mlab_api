class StockOrder < RetirableRecord
  validates :identifier, uniqueness: true, presence: true
end
