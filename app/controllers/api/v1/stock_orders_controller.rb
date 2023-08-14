module Api
  module V1
    class StockOrdersController < ApplicationController
      before_action :read, only: %i[ show update destroy ]
      def index
        orders = StockOrder.includes(:user, :stock_order_statuses, :stock_requisitions)
        render json: {
          data: orders.as_json(include: {
            user: { only: [:id, :username, :creator] },
          }, methods: [:statuses, :requisitions])
        }
      end
      def create
        service = Stocks::StockService.new(order_params, requisitions_params)
        result = service.create_order_and_requisitions

        if result.key?(:error)
          render json: { error: result[:error] }, status: :unprocessable_entity
        else
          render json: { message: result[:message] }, status: :created
        end
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
      def requisitions_params
        params.require(:stock_requisitions).map do |requisition_params|
          requisition_params.permit(:quantity_requested, :quantity_issued, :quantity_collected, :stock_id)
        end
      end
      def read
        @order = StockOrder.find(params[:id])
      end
    end
  end
end
