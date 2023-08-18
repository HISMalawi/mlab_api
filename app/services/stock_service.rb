# frozen_string_literal: true

# stock service
module StockService
  class << self
    def search(item, page: 1, limit: 10)
      data = Stock.joins(:stock_id, :stock_location_id).where('stock_items.name LIKE ? OR stock_locations.name LIKE ?',
                                                              "%#{item}%", "%#{item}%")
                  .select('stocks.id, stocks.quantity, stock_items.name as stock_item,
                    stock_locations.name as stock_location')
      records = PaginationService.paginate(data, page:, limit:)
      { data: records, meta: PaginationService.pagination_metadata(records) }
    end

    def stock_list
      Stock.joins(:stock_item,
                  :stock_location).select('stocks.id, stocks.quantity, stock_items.name as stock_item,
                    stock_locations.name as stock_location')
    end
  end
end
