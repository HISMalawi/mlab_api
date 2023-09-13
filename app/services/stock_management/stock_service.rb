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

      def stock_transaction(stock_id, transaction_type, quantity, params)
        lot = params[:lot]
        batch = params[:batch]
        expiry_date = params[:expiry_date]
        receiving_from = if params[:receiving_from].nil? && positive_stock_adjustment_transaction_type?(transaction_type)
                           'Pharmacy'
                         else
                           params[:receiving_from]
                         end
        received_by = positive_stock_adjustment_transaction_type?(transaction_type) ? User.current.id : nil
        sending_to = params[:sending_to]
        optional_receiver = params[:optional_receiver]
        remarks = params[:remarks]
        balance = stock_transaction_calculate_remaining_balance(stock_id, lot, batch, expiry_date, quantity, transaction_type)
        last_stock_transaction = last_stock_transaction(stock_id, lot, batch, expiry_date)
        lot = last_stock_transaction&.lot.nil? ? lot : last_stock_transaction&.lot
        batch = last_stock_transaction&.batch.nil? ? batch : last_stock_transaction&.batch
        expiry_date = last_stock_transaction&.expiry_date.nil? ? expiry_date : last_stock_transaction&.expiry_date
        StockTransaction.create!(
          stock_id:,
          stock_transaction_type_id: StockTransactionType.find_by(name: transaction_type).id,
          lot:,
          quantity:,
          batch:,
          expiry_date:,
          receiving_from:,
          sending_to:,
          received_by:,
          optional_receiver:,
          remarks:,
          remaining_balance: balance
        )
      end

      def issue_stock_out(transaction_type, params)
        sending_to = params[:sending_to]
        stock_status_reason = params[:stock_status_reason]
        ActiveRecord::Base.transaction do
          stock_movement = stock_movement_record(transaction_type, sending_to)
          params[:stock_items].each do |stock_item|
            lot = stock_item[:lot]
            batch = stock_item[:batch]
            expiry_date = stock_item[:expiry_date]
            quantity_to_issue = stock_item[:quantity]
            stock = Stock.find_by(stock_item_id: stock_item[:stock_item_id])
            return false unless stock_deduction_allowed?(stock.id, lot, batch, expiry_date, quantity_to_issue)

            stock_item[:sending_to] = sending_to
            stock_transaction = stock_transaction(stock.id, transaction_type, quantity_to_issue, params)
            stock_movement_status(stock_transaction.id, 'Pending', stock_status_reason, stock_movement.id)
          end
        end
      end

      def approve_stock_movement(stock_movement_id)
        stock_movement_statuses = StockMovementStatus.where(stock_movement_id:)
        ActiveRecord::Base.transaction do
          stock_movement_statuses.each do |stock_movement_stat|
            next if stock_movement_already_approved?(stock_movement_stat.stock_transactions_id, stock_movement_id)

            stock_movement_status(stock_movement_stat.stock_transactions_id, 'Approved', nil, stock_movement_id)
            stock_transaction = StockTransaction.find(stock_movement_stat.stock_transactions_id)
            negative_stock_adjustment(Stock.find(stock_transaction.stock_id), stock_transaction.quantity)
          end
        end
      end

      def reject_stock_movement(stock_movement_id, stock_status_reason, transaction_type)
        stock_movement_statuses = StockMovementStatus.where(
          stock_movement_id:,
          stock_status_id: StockStatus.find_by(name: 'Pending').id
        )
        ActiveRecord::Base.transaction do
          stock_movement_statuses.each do |stock_movement_stat|
            next if stock_movement_already_approved?(stock_movement_stat.stock_transactions_id, stock_movement_id)

            stock_transaction = reverse_stock_transaction(
              stock_movement_stat.stock_transactions_id,
              stock_status_reason,
              transaction_type
            )
            stock_movement_status(stock_transaction.id, 'Rejected', stock_status_reason, stock_movement_id)
          end
        end
      end

      def reverse_stock_transaction(stock_transaction_id, reason, transaction_type, quantity = nil, notes = nil)
        stock_transaction = StockTransaction.find(stock_transaction_id)
        quantity = quantity.present? ? quantity.to_i : stock_transaction.quantity
        StockTransaction.create!(
          stock_id: stock_transaction.stock_id,
          stock_transaction_type_id: StockTransactionType.find_by(name: transaction_type).id,
          lot: stock_transaction.lot,
          quantity:,
          batch: stock_transaction.batch,
          expiry_date: stock_transaction.expiry_date,
          receiving_from: stock_transaction.sending_to,
          sending_to: stock_transaction.receiving_from,
          received_by: stock_transaction.optional_receiver,
          optional_receiver: stock_transaction.received_by,
          remarks: notes,
          remaining_balance: stock_transaction.remaining_balance + quantity,
          reason:
        )
      end

      def stock_movement_already_approved?(stock_transactions_id, stock_movement_id)
        StockMovementStatus.where(
          stock_transactions_id:,
          stock_status_id: StockStatus.find_by(name: 'Approved').id,
          stock_movement_id:
        ).present?
      end

      def stock_movement_record(transaction_type, movement_to)
        StockMovement.create!(
          stock_transaction_type_id: StockTransactionType.find_by(name: transaction_type).id,
          movement_to:
        )
      end

      def stock_movement_status(stock_transactions_id, status, stock_status_reason, stock_movement_id)
        StockMovementStatus.find_or_create_by!(
          stock_transactions_id:,
          stock_status_id: StockStatus.find_by(name: status).id,
          stock_status_reason:,
          stock_movement_id:
        )
      end

      def stock_deduction_allowed?(stock_id, lot, batch, expiry_date, quantity)
        stock_transaction = last_stock_transaction(stock_id, lot, batch, expiry_date)
        stock_transaction.present? && stock_transaction.remaining_balance >= quantity.to_i
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

      def receive_stock_from_supplier_or_facility(params)
        ActiveRecord::Base.transaction do
          params[:stock_items].each do |stock_item|
            stock = Stock.find_by(stock_item_id: stock_item[:stock_item_id])
            stock_item[:receiving_from] = params[:receiving_from]
            stock_item[:sending_to] = params[:sending_to]
            stock_transaction(stock.id, 'In', stock_item[:quantity], stock_item)
            positive_stock_adjustment(stock.id, stock_item[:quantity])
          end
        end
      end

      # Should be called after requisition is approved
      def positive_stock_adjustment(stock_item_id, quantity)
        stock = Stock.find_by_stock_item_id(stock_item_id)
        return if stock.nil?

        stock.update!(quantity: stock.quantity + quantity.to_i)
      end

      # Should be called after stock is issued out/ expired / disposed
      def negative_stock_adjustment(stock, quantity)
        return if stock.nil?

        stock.update!(quantity: stock.quantity - quantity.to_i)
      end
    end
  end
end
