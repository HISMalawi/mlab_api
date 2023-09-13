# frozen_string_literal: true

# module Api
module Api
  # module V1
  module V1
    # stock report controller
    class StockReportsController < ApplicationController
      def stock_movement_report
        from = params[:from]
        to = params[:to]
        transaction_type = params[:transaction_type]
        page = params[:page]
        limit = params[:per_page]
        stock_movements = StockManagement::Report::StockMovementService.stock_movements(
          from, to, transaction_type, page:, limit:
        )
        render json: stock_movements
      end
    end
  end
end
