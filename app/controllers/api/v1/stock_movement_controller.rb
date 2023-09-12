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

      def stock_transaction_list
        stock_transactions = if params[:search].present?
                               items = StockManagement::StockFetcherService.search_stock(
                                 params[:search],
                                 page: params[:page],
                                 limit: params[:limit]
                               )
                               stock_list = []
                               meta = {}
                               items[:data].each do |stock|
                                 stock_list = PaginationService.paginate_array(
                                   StockManagement::StockFetcherService.stock_transactions(stock:,
                                                                                           limit: params[:limit]),
                                   page: params[:page],
                                   limit: params[:limit]
                                 )
                                 meta = PaginationService.pagination_metadata(stock_list)
                                 stock_list = stock_list.map do |stock_transaction|
                                   JSON.parse(stock_transaction.attributes.to_json)
                                 end
                               end
                               { data: stock_list,
                                 meta: }
                             else
                               transactions = PaginationService.paginate_array(
                                 StockManagement::StockFetcherService.stock_transactions,
                                 page: params[:page],
                                 limit: params[:limit]
                               )
                               { data: transactions.map do |stock_transaction|
                                         JSON.parse(stock_transaction.attributes.to_json)
                                       end,
                                 meta: PaginationService.pagination_metadata(transactions) }
                             end
        render json: stock_transactions
      end

      # TODO: Get stock items and their corresponding transactions
      def stock_items_with_respective_transaction
        search_query = params[:search].present? ? params[:search] : ''
        items = StockManagement::StockFetcherService.search_stock(
          search_query,
          page: params[:page],
          limit: params[:limit]
        )
        render json: StockManagement::StockFetcherService.stock_transaction_list_per_stocks(items)
      end

      # TODO: Get stock movement and their corresponding transactions
      def stock_movement_with_respective_transaction
        stock_movement_statuses = StockManagement::StockMovementService.stock_movement_statuses
        stock_movements = StockManagement::StockMovementService.stock_movements(stock_movement_statuses)
        stock_movements = PaginationService.paginate_array(stock_movements, page: params[:page], limit: params[:limit])
        render json: {
          data: stock_movements,
          meta: PaginationService.pagination_metadata(stock_movements)
        }
      end
    end
  end
end
