module Api
  module V1
    class StockOrdersController < ApplicationController
      before_action :read, only: %i[ show update destroy ]
      def index
        orders = StockOrder.all
        render json: { data: orders.as_json(include: [:stock_requisitions])  }
      end
      def create
        order = StockOrder.create!(order_params)
        render json: { status: :ok, message: 'Stock order created successfully' }
      end
      def update
        @order = @order.update!(order_params)
        render json: { status: :ok, message: 'Stock order updated successfully' }
      end
      def destroy
        render json: @order.void(order_params[:voided_reason])
      end
      private
      def order_params
        params.require(:stock_order).permit(:id, :identifier)
      end
      def read
        @order = StockOrder.find(params[:id])
      end
    end
  end
end
