module Api
  module V1
    class StockOrderStatusController < ApplicationController
      before_action :read, only: %i[ show update destroy ]
      def index
        stock_order_status = StockOrderStatus.all
        render json: stock_order_status
      end
      def create
        supplier = StockOrderStatus.create!(stock_order_status)
        render json: { message: "Stock order status created successfully" }
      end
      def update
        @status = @status.update!(stock_order_status)
        render json: { message: "Stock order status updated successfully" }
      end
      def destroy
        render json: @status.void(category_params[:voided_reason])
      end
      private
      def stock_order_status
        params.require(:stock_order_status).permit(:stock_order_id, :status_id)
      end
      def read
        @status = StockOrderStatus.find(params[:id])
      end
    end
  end
end
