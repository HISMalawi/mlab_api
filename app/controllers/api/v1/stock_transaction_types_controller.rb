# frozen_string_literal: true

# module Api
module Api
  # module V1
  module V1
    # stock transaction type controller
    class StockTransactionTypesController < ApplicationController
      before_action :set_stock_transaction_type, only: %i[show update destroy]

      def index
        stock_transaction_types = StockTransactionType.all
        render json: stock_transaction_types
      end

      def create
        stock_transaction_type = StockTransactionType.create!(stock_transaction_type_params)
        render json: stock_transaction_type, status: :created
      end

      def show
        render json: @stock_transaction_type
      end

      def update
        @stock_transaction_type.update!(stock_transaction_type_params)
        render json: @stock_transaction_type, status: :ok
      end

      def destroy
        @stock_transaction_type.void(params.require(:reason))
        render json: { message: MessageService::RECORD_DELETED }
      end

      private

      def stock_transaction_type_params
        params.require(:stock_transaction_type).permit(:name)
      end

      def set_stock_transaction_type
        @stock_transaction_type = StockTransactionType.find(params[:id])
      end
    end
  end
end
