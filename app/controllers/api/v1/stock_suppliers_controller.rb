module Api
  module V1
    class StockSuppliersController < ApplicationController
      before_action :read, only: %i[ show update destroy ]
      def index
        suppliers = StockSupplier.all
        render json: suppliers
      end
      def create
        supplier = StockSupplier.create!(supplier_params)
        render json: { message: "#{supplier.name} created successfully" }
      end
      def update
        @supplier = @supplier.update!(supplier_params)
        render json: { message: "Stock supplier updated successfully" }
      end
      def destroy
        render json: @supplier.void(category_params[:voided_reason])
      end
      private
      def supplier_params
        params.require(:stock_supplier).permit(:id, :name, :address)
      end
      def read
        @supplier = StockSupplier.find(params[:id])
      end
    end
  end
end
