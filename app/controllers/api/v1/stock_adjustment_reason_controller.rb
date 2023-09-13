# frozen_string_literal: true

# module Api
module Api
  # module V1
  module V1
    # stock adjustment reason controller
    class StockAdjustmentReasonController < ApplicationController
      before_action :set_stock_adjustment_reason, only: %i[show update destroy]

      def index
        stock_adjustment_reasons = StockAdjustmentReason.all
        render json: stock_adjustment_reasons
      end

      def create
        stock_adjustment_reason = StockAdjustmentReason.create!(stock_adjustment_reason_params)
        render json: stock_adjustment_reason, status: :created
      end

      def show
        render json: @stock_adjustment_reason
      end

      def update
        @stock_adjustment_reason.update!(stock_adjustment_reason_params)
        render json: @stock_adjustment_reason, status: :ok
      end

      def destroy
        @stock_adjustment_reason.void(params.require(:reason))
        render json: { message: MessageService::RECORD_DELETED }
      end

      private

      def stock_adjustment_reason_params
        params.require(:stock_adjustment_reason).permit(:name)
      end

      def set_stock_adjustment_reason
        @stock_adjustment_reason = StockAdjustmentReason.find(params[:id])
      end
    end
  end
end
