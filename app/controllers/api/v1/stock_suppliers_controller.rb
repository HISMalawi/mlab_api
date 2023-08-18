class Api::V1::StockSuppliersController < ApplicationController
end
# frozen_string_literal: true

# module Api
module Api
  # module V1
  module V1
    # stock suppliers controller
    class StockSuppliersController < ApplicationController
      before_action :set_stock_supplier, only: %i[show update destroy]

      def index
        stock_suppliers = StockSupplier.all
        render json: stock_suppliers
      end

      def create
        stock_supplier = StockSupplier.create!(stock_supplier_params)
        render json: stock_supplier, status: :created
      end

      def show
        render json: @stock_supplier
      end

      def update
        @stock_supplier.update!(stock_supplier_params)
        render json: @stock_supplier, status: :ok
      end

      def destroy
        @stock_supplier.void(params.require(:reason))
        render json: { message: MessageService::RECORD_DELETED }
      end

      private

      def stock_supplier_params
        params.require(:stock_supplier).permit(:name)
      end

      def set_stock_supplier
        @stock_supplier = StockSupplier.find(params[:id])
      end
    end
  end
end
