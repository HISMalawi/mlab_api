# frozen_string_literal: true

# module Api
module Api
  # module V1
  module V1
    # stock unit controller
    class StockItemsController < ApplicationController
      before_action :set_stock_item, only: %i[show update destroy]

      def index
        stock_items = StockItem.all
        render json: stock_items
      end

      def create
        stock_item = StockItem.create!(stock_item_params)
        render json: stock_item, status: :created
      end

      def show
        render json: @stock_item
      end

      def update
        @stock_item.update!(stock_item_params)
        render json: @stock_item, status: :ok
      end

      def destroy
        @stock_item.void(params.require(:reason))
        render json: { message: MessageService::RECORD_DELETED }
      end

      private

      def stock_item_params
        params.require(:stock_item).permit(:name, :stock_category_id, :description, :measurement_unit, :quantity_unit)
      end

      def set_stock_item
        @stock_item = StockItem.find(params[:id])
      end
    end
  end
end
