# frozen_string_literal: true

# stock management module
module StockManagement
  # stock service
  module StockService
    class << self
      def search(item, page: 1, limit: 10)
        data = Stock.joins(:stock_item, :stock_location).where('stock_items.name LIKE ? OR stock_locations.name LIKE ?',
                                                               "%#{item}%", "%#{item}%")
                    .select('stocks.*, stocks.quantity, stock_items.name as stock_item,
                      stock_locations.name as stock_location')
        records = PaginationService.paginate(data, page:, limit:)
        { data: records, meta: PaginationService.pagination_metadata(records) }
      end

      def stock_list
        Stock.joins(:stock_item,
                    :stock_location).select('stocks.*, stocks.quantity, stock_items.name as stock_item,
                      stock_locations.name as stock_location')
      end

      def create_stock_order(voucher_number, requisitions)
        # Create stock order -> stock requisitions -> stock order status -> stock transaction
        # Order: Draft -> Pending -> Received -> Approved/Reject
        # Req status: Draft -> Requested -> Received -> Approved/Reject/Not collected
        ActiveRecord::Base.transaction do
          stock_order = StockOrder.create!(voucher_number:)
          requisitions.each do |requisition|
            StockRequisition.create!(stock_order_id: stock_order.id, stock_item_id: requisition[:stock_item_id],
                                     quantity_requested: requisition[:quantity_requested])
          end
        end
      end
    end
  end
end
