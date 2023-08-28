# frozen_string_literal: true

# module Api
module Api
  # module V1
  module V1
    # stock controller
    class StockOrderStatusesController < ApplicationController
      def approve_stock_order_request
        StockManagement::StockOrderService.approve_stock_order_request(
          params.require(:stock_order_id),
          params.require(:stock_requisition_ids)
        )
        render json: { message: MessageService::STOCK_ORDER_APPROVED }
      end

      def reject_stock_order
        StockManagement::StockOrderService.reject_stock_order(
          params.require(:stock_order_id),
          params.require(:stock_status_reason)
        )
        render json: { message: MessageService::STOCK_ORDER_REJECTED }
      end

      def approve_stock_requisition_request
        StockManagement::StockOrderService.approve_stock_requisition_request(
          params.require(:stock_requisition_id)
        )
        render json: { message: MessageService::STOCK_REQUISITION_APPROVED }
      end

      def reject_stock_requisition
        StockManagement::StockOrderService.reject_stock_requisition(
          params.require(:stock_requisition_id),
          params.require(:stock_status_reason)
        )
        render json: { message: MessageService::STOCK_REQUISITION_REJECTED }
      end

      def receive_stock_requisition
        StockManagement::StockOrderService.receive_stock_requisition(
          params.require(:stock_requisition_id), params[:requisition], params[:transaction]
        )
        render json: { message: MessageService::STOCK_REQUISITION_RECEIVED }
      end

      def approve_stock_requisition
        StockManagement::StockOrderService.approve_stock_requisition(
          params.require(:stock_requisition_id)
        )
        render json: { message: MessageService::STOCK_REQUISITION_APPROVED }
      end

      def approve_stock_order_receipt
        StockManagement::StockOrderService.approve_stock_order_receipt(
          params.require(:stock_order_id),
          params.require(:stock_requisition_ids)
        )
        render json: { message: MessageService::STOCK_ORDER_APPROVED }
      end

      def stock_requisition_not_collected
        StockManagement::StockOrderService.stock_requisition_not_collected(
          params.require(:stock_requisition_id),
          params.require(:stock_status_reason)
        )
        render json: { message: MessageService::STOCK_REQUISITION_NOT_COLLECTED }
      end
    end
  end
end
