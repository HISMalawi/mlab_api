module Stocks
  class StockService
    def self.read(stock_id)
      Stock.includes(:stock_category, :stock_location).find(stock_id)
    end
  end
end
