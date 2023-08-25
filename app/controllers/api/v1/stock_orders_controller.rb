# frozen_string_literal: true

# module Api
module Api
  # module V1
  module V1
    # stock orders controller
    class StockOrdersController < ApplicationController
      before_action :set_stock_order, only: %i[show update destroy]

      def index
        stock_orders = StockOrder.all
        render json: stock_orders
      end

      def create
        StockManagement::StockService.create_stock_order(
          params[:voucher_number], params[:requisitions]
        )
        render json: { message: MessageService::RECORD_CREATED }, status: :created
      end

      def check_voucher_number_if_already_used
        render json: {
          used: StockManagement::StockService.voucher_number_already_used?(params[:voucher_number])
        }
      end

      def show
        render json: @stock_order
      end

      def update
        @stock_order.update!(params)
        render json: @stock_order, status: :ok
      end

      def destroy
        @stock_order.void(params.require(:reason))
        render json: { message: MessageService::RECORD_DELETED }
      end

      private

      def set_stock_order
        @stock_order = StockOrder.find(params[:id])
      end
    end
  end
end
