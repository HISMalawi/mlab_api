# frozen_string_literal: true

# module Api
module Api
  # module V1
  module V1
    # stock controller
    class StocksController < ApplicationController
      before_action :set_stock, only: %i[show update destroy]

      def index
        stocks = if params[:search].blank?
                   paginate(StockManagement::StockService.stock_list)
                 else
                   StockManagement::StockService.search_stock(params[:search])
                 end
        render json: stocks
      end

      def create
        stock = Stock.create!(stock_params)
        render json: stock, status: :created
      end

      def show
        stock = JSON.parse(@stock.attributes.to_json)
        stock[:stock_item_name] = @stock.stock_item.name
        render json: stock
      end

      def update
        @stock.update!(stock_params)
        render json: @stock, status: :ok
      end

      def destroy
        @stock.void(params.require(:reason))
        render json: { message: MessageService::RECORD_DELETED }
      end

      private

      def stock_params
        params.require(:stock).permit(:quantity, :stock_item_id, :stock_location_id)
      end

      def set_stock
        @stock = Stock.find(params[:id])
      end
    end
  end
end
