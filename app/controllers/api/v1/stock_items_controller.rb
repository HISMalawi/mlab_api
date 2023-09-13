# frozen_string_literal: true

# module Api
module Api
  # module V1
  module V1
    # stock item controller
    class StockItemsController < ApplicationController
      before_action :set_stock_item, only: %i[show update destroy]

      def index
        stock_items = Stock.joins(:stock_item).select(
          'stock_items.*, stocks.stock_location_id, stocks.minimum_order_level, stocks.quantity'
        )
        render json: stock_items
      end

      def create
        ActiveRecord::Base.transaction do
          @stock_item = StockItem.create!(stock_item_params)
          Stock.create!(
            stock_item_id: @stock_item.id,
            stock_location_id: params.require(:stock_location_id),
            quantity: 0,
            minimum_order_level: params.require(:minimum_order_level)
          )
        end
        render json: @stock_item, status: :created
      end

      def show
        stock = Stock.find_by_stock_item_id(@stock_item.id)
        stock_item = JSON.parse(@stock_item.attributes.to_json)
        stock_item[:stock] = stock
        render json: stock_item
      end

      def update
        @stock_item.update!(stock_item_params)
        stock = Stock.find_by_stock_item_id(@stock_item.id)
        stock.update!(
          stock_item_id: @stock_item.id,
          stock_location_id: params.require(:stock_location_id),
          minimum_order_level: params.require(:minimum_order_level).to_i
        )
        render json: @stock_item, status: :ok
      end

      def destroy
        @stock_item.void(params.require(:reason))
        render json: { message: MessageService::RECORD_DELETED }
      end

      private

      def stock_item_params
        params.require(:stock_item).permit(
          :name,
          :stock_category_id,
          :description,
          :measurement_unit,
          :quantity_unit,
          :strength
        )
      end

      def set_stock_item
        @stock_item = StockItem.find(params[:id])
      end
    end
  end
end
