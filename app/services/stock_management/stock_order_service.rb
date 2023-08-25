# frozen_string_literal: true

# module stock management
module StockManagement
  # module stock order service
  module StockOrderService
    class << self
      def update_stock_order_status(stock_order_id, status, stock_status_reason = nil)
        StockOrderStatus.find_or_create_by!(
          stock_order_id:,
          stock_status_id: StockStatus.find_by(name: status).id,
          stock_status_reason:
        )
      end

      def update_stock_requisition_status(stock_requisition_id, status, stock_status_reason = nil)
        RequisitionStatus.find_or_create_by!(
          stock_requisition_id:,
          stock_status_id: StockStatus.find_by(name: status).id,
          stock_status_reason:
        )
      end

      def stock_requesition_rejected?(stock_requisition_id)
        stock_requisition_status = RequisitionStatus.where(stock_requisition_id:)
                                                    .order(created_date: :desc)&.first&.stock_status&.name
        stock_requisition_status == 'Rejected'
      end

      def approve_stock_order_request(stock_order_id, stock_requisitions)
        ActiveRecord::Base.transaction do
          update_stock_order_status(stock_order_id, 'Requested')
          stock_requisitions.each do |requisition|
            next if stock_requesition_rejected?(requisition)

            update_stock_requisition_status(requisition, 'Requested')
          end
        end
      end

      def reject_stock_order(stock_order_id, stock_status_reason)
        ActiveRecord::Base.transaction do
          stock_order = StockOrder.find(stock_order_id)
          update_stock_order_status(stock_order.id, 'Rejected', stock_status_reason)
          stock_order.stock_requisitions.each do |requisition|
            next if stock_requesition_rejected?(requisition.id)

            update_stock_requisition_status(requisition.id, 'Rejected', stock_status_reason)
          end
        end
      end

      def reject_stock_requisition(stock_requisition_id, stock_status_reason)
        update_stock_requisition_status(stock_requisition_id, 'Rejected', stock_status_reason)
      end

      def receive_stock_requisition(stock_requisition_id, requisition_params, transaction_params)
        ActiveRecord::Base.transaction do
          stock_requisition = StockRequisition.find(stock_requisition_id)
          stock_requisition.update!(
            quantity_issued: requisition_params[:quantity_issued],
            quantity_received: requisition_params[:quantity_received]
          )
          StockManagement::StockService.stock_transaction(
            stock_requisition.stock_item_id,
            'In',
            stock_requisition.quantity_received,
            transaction_params
          )
          update_stock_requisition_status(stock_requisition_id, 'Received')
        end
      end

      def stock_requisition_not_collected(stock_requisition_id, stock_status_reason)
        update_stock_requisition_status(stock_requisition_id, 'Not Collected', stock_status_reason)
      end

      def approve_stock_requisition(stock_requisition_id)
        next if stock_requesition_rejected?(stock_requisition_id)

        update_stock_requisition_status(stock_requisition_id, 'Approved')
        return unless stock_requisition_receipt_approved?(stock_requisition_id)

        stock_requisition = StockRequisition.find(stock_requisition_id)
        StockManagement::StockService.positive_stock_adjustment(
          stock_requisition.stock_item_id,
          stock_requisition.quantity_requested
        )
      end

      def approve_stock_order_receipt(stock_order_id, stock_requisitions)
        ActiveRecord::Base.transaction do
          update_stock_order_status(stock_order_id, 'Approved')
          stock_requisitions.each do |requisition|
            next if stock_requesition_rejected?(requisition)

            update_stock_requisition_status(requisition, 'Approved')
            next unless stock_requisition_receipt_approved?(requisition)

            StockManagement::StockService.positive_stock_adjustment(
              requisition.stock_item_id,
              requisition.quantity_requested
            )
          end
        end
      end

      def stock_requisition_receipt_approved?(stock_requisition_id)
        RequisitionStatus.where(stock_requisition_id:)&.order(
          created_date: :desc
        )&.first&.stock_status&.name == 'Approved'
      end
    end
  end
end
