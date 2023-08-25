# frozen_string_literal: true

# stock management module
module StockManagement
  # stock service
  module StockService
    class << self
      def search_stock(item, page: 1, limit: 10)
        data = Stock.joins(:stock_item, :stock_location)
                    .where('stock_items.name LIKE ? OR stock_locations.name LIKE ?', "%#{item}%", "%#{item}%")
                    .select('
                      stocks.*,
                      stock_items.name as stock_item,
                      stock_locations.name as stock_location
                    ')
        records = PaginationService.paginate(data, page:, limit:)
        { data: records, meta: PaginationService.pagination_metadata(records) }
      end

      def stock_list
        Stock.joins(:stock_item, :stock_location)
             .select('
                stocks.*,
                stock_items.name as stock_item,
                stock_locations.name as stock_location
              ')
      end

      def voucher_number_already_used?(voucher_number)
        StockOrder.find_by(voucher_number:).present?
      end

      def create_stock_order(voucher_number, requisitions)
        # Create stock order -> stock requisitions -> stock order status -> stock transaction
        # Order: Draft -> Pending -> Received -> Approved/Reject
        # Req status: Draft -> Requested -> Received -> Approved/Reject/Not collected
        ActiveRecord::Base.transaction do
          stock_order = StockOrder.create!(voucher_number:)
          requisitions.each do |requisition|
            StockRequisition.create!(
              stock_order_id: stock_order.id,
              stock_item_id: requisition[:stock_item_id],
              quantity_requested: requisition[:quantity_requested]
            )
          end
        end
      end

      # Discuss with team, the below 3 methods should be in stock service or stock order service
      # Discuss with team how to handle stock transaction and updatin stocks in consideration of different stock transaction types
      # Discuss with team whether its ideal to create stocks with default zero quantity whenever a stock item is created
      def stock_transaction(stock_item_id, transaction_type, quantity, params)
        stock_id = Stock.find_by(stock_item_id:).id
        StockTransaction.create!(
          stock_id:,
          stock_transaction_type_id: StockTransactionType.find_by(name: transaction_type).id,
          lot: params[:lot],
          quantity:,
          batch: params[:batch],
          expire_date: params[:expire_date],
          receiving_from: params[:receiving_from],
          sending_to: params[:sending_to],
          received_by: User.current.id,
          optional_receiver: params[:optional_receiver],
          remarks: params[:remarks]
        )
      end

      # Should be called after requisition is approved
      def positive_stock_adjustment(stock_id, quantity)
        stock = Stock.find(stock_id)
        stock.update!(quantity: stock.quantity + quantity)
      end

      # Should be called after stock is issued out/ expired / disposed
      def negative_stock_adjustment(stock_id, quantity)
        stock = Stock.find(stock_id)
        stock.update!(quantity: stock.quantity - quantity)
      end
    end
  end
end
