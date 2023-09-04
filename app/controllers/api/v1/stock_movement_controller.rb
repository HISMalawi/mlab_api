# frozen_string_literal: true

# module Api
module Api
  # module V1
  module V1
    # class StockOrdersController
    class StockMovementController < ApplicationController
      def stock_deduction_allowed
        stock_id = Stock.find_by(stock_item_id: params.require(:stock_item_id)).id
        deduction_allowed = StockManagement::StockService.stock_deduction_allowed?(
          stock_id,
          params[:lot],
          params[:batch],
          params[:expiry_date],
          params[:quantity]
        )
        message = deduction_allowed ? 'Deduction allowed' : 'Deduction not allowed, insufficient stock'
        render json: { deduction_allowed:, message: }
      end

      def issue_stock_out
        stock = Stock.find_by(stock_item_id: params.require(:stock_item_id))
        _ = params.require(:sending_to)
        issued = StockManagement::StockService.issue_stock_out(stock, params)
        message = issued ? 'Stock issued successfully' : 'Stock not issued, insufficient stock'
        render json: { message: }
      end
    end
  end
end
