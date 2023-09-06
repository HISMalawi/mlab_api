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
        issued = StockManagement::StockService.issue_stock_out('Out', params)
        message = issued ? 'Stock issued successfully' : 'Stock not issued, insufficient stock'
        render json: { message: }
      end

      def approve_stock_movement
        approved = StockManagement::StockService.approve_stock_movement(params.require(:stock_movement_id))
        message = approved ? 'Stock movement approved successfully' : 'Stock movement not approved'
        render json: { message: }
      end

      # TODO: Get stock items and their corresponding transactions
      def stock_items_with_respective_transaction
        search_query = params[:search].present? ? params[:search] : ''
        items = StockManagement::StockFetcherService.search_stock(
          search_query,
          page: params[:page],
          limit: params[:limit]
        )
        render json: StockManagement::StockFetcherService.stock_transaction_list(items)
      end
      # TODO: Get stock movement and their corresponding transactions
    end
  end
end
