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

      def stock_transaction(stock_item_id, transaction_type, quantity, params)
        stock_id = Stock.find_by(stock_item_id:).id
        lot = params[:lot]
        batch = params[:batch]
        expiry_date = params[:expiry_date]
        receiving_from = if params[:receiving_from].nil? && positive_stock_adjustment_transaction_type?(transaction_type)
                           'Pharmacy'
                         else
                           params[:receiving_from]
                         end
        sending_to = params[:sending_to]
        optional_receiver = params[:optional_receiver]
        remarks = params[:remarks]
        balance = stock_transaction_calculate_remaining_balance(stock_id, lot, batch, expiry_date, quantity, transaction_type)
        StockTransaction.create!(
          stock_id:,
          stock_transaction_type_id: StockTransactionType.find_by(name: transaction_type).id,
          lot:,
          quantity:,
          batch:,
          expiry_date:,
          receiving_from:,
          sending_to:,
          received_by: User.current.id,
          optional_receiver:,
          remarks:,
          remaining_balance: balance
        )
      end

      def issue_stock_out(stock_id, lot, batch, expiry_date, quantity_to_issue, sending_to)
        params = {
          lot:,
          batch:,
          expiry_date:,
          sending_to:
        }
        return if stock_deduction_allowed?(stock_id, lot, batch, expiry_date, quantity_to_issue)

        stock_transaction(stock_id, 'Out', quantity_to_issue, params)
      end

      def stock_deduction_allowed?(stock_id, lot, batch, expiry_date, quantity)
        stock_transaction = last_stock_transaction(stock_id, lot, batch, expiry_date)
        quantity = quantity.to_i
        stock_transaction.present? && stock_transaction.remaining_balance >= quantity
      end

      def last_stock_transaction(stock_id, lot, batch, expiry_date)
        stock_transaction = StockTransaction.where(stock_id:)
        stock_transaction = stock_transaction.where(lot:) if lot.present?
        stock_transaction = stock_transaction.where(batch:) if batch.present?
        stock_transaction = stock_transaction.where(expiry_date:) if expiry_date.present?
        stock_transaction.order(created_date: :desc).first
      end

      def positive_stock_adjustment_transaction_type?(transaction_type)
        ['In'].include?(transaction_type)
      end

      def stock_transaction_calculate_remaining_balance(stock_id, lot, batch, expiry_date, quantity, transaction_type)
        stock_transaction = last_stock_transaction(stock_id, lot, batch, expiry_date)
        remaining_balance = stock_transaction&.remaining_balance.nil? ? 0 : stock_transaction&.remaining_balance
        quantity = quantity.to_i
        if stock_transaction.nil?
          quantity
        elsif positive_stock_adjustment_transaction_type?(transaction_type)
          remaining_balance + quantity
        else
          remaining_balance - quantity
        end
      end

      # Should be called after requisition is approved
      def positive_stock_adjustment(stock_item_id, quantity)
        stock = Stock.find_by_stock_item_id(stock_item_id)
        return if stock.nil?

        stock.update!(quantity: stock.quantity + quantity.to_i)
      end

      # Should be called after stock is issued out/ expired / disposed
      def negative_stock_adjustment(stock_item_id, quantity)
        stock = Stock.find_by_stock_item_id(stock_item_id)
        return if stock.nil?

        stock.update!(quantity: stock.quantity - quantity.to_i)
      end
    end
  end
end
