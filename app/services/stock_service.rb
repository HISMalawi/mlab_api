# frozen_string_literal: true

# stock service
module StockService
  class << self
    def search(item)
      Stock.where(stock_item_id: StockItem.where('name LIKE ?', "%#{item}%").pluck(:id))
    end

    def serialize_stock(stocks)
      stocks.map do |stock|
        {
          stock_item: stock.stock_item.name,
          stock_location: stock.stock_location.name,
          quantity: stock.quantity,
          creator: User.find(stock.creator).full_name
        }
      end
    end
  end
end
