# frozen_string_literal: true

# module Api
module Api
  # module V1
  module V1
    # stock controller
    class StockOrderStatusesController < ApplicationController
      def approve_stock_order
        stock_order_id = params[:stock_order_id]
        approved = StockManagement::StockOrderService.approve_stock_order(stock_order_id)
        render json: { message: MessageService::STOCK_ORDER_APPROVED } if approved
      end

      def reject_stock_order
        stock_order_id = params[:stock_order_id]
        rejected = StockManagement::StockOrderService.reject_stock_order(stock_order_id, params[:stock_status_reason])
        render json: { message: MessageService::STOCK_ORDER_REJECTED } if rejected
      end

      def reject_stock_requisition
        stock_requisition_id = params[:stock_requisition_id]
        rejected = StockManagement::StockOrderService.reject_stock_requisition(
          stock_requisition_id,
          params[:stock_status_reason]
        )
        render json: { message: MessageService::STOCK_REQUISITION_REJECTED } if rejected
      end
    end
  end
end
