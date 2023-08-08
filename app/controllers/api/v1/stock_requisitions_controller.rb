module Api
  module V1
    class StockRequisitionsController < ApplicationController
      before_action :read, only: %i[ show update destroy ]
      def index
        requisitions = StockRequisition.all
        render json: { data: requisitions.as_json(include: [:stock, :stock_order])  }
      end
      def create
        requisition = StockRequisition.create!(requisition_params)
        render json: { message: 'Stock requisition added successfully'}
      end
      def update
        @requisition = @requisition.update!(requisition_params)
        render json: { message: 'Stock requisition updated successfully' }
      end
      def destroy
        render json: @supplier.void(category_params[:voided_reason])
      end
      private
      def requisition_params
        params.require(:stock_requisition).permit(:id, :quantity_requested, :quantity_issued, :quantity_collected, :stock_id, :stock_order_id)
      end
      def read
        @requisition = StockRequisition.find(params[:id])
      end
    end
  end
end
