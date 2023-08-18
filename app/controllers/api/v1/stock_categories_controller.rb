# frozen_string_literal: true

# module Api
module Api
  # module V1
  module V1
    # stock categories controller
    class StockCategoriesController < ApplicationController
      before_action :set_stock_category, only: %i[show update destroy]

      def index
        stock_categories = StockCategory.all
        render json: stock_categories
      end

      def create
        stock_category = StockCategory.create!(stock_category_params)
        render json: stock_category, status: :created
      end

      def show
        render json: @stock_category
      end

      def update
        @stock_category.update!(stock_category_params)
        render json: @stock_category, status: :ok
      end

      def destroy
        @stock_category.void(params.require(:reason))
        render json: { message: MessageService::RECORD_DELETED }
      end

      private

      def stock_category_params
        params.require(:stock_category).permit(:name)
      end

      def set_stock_category
        @stock_category = StockCategory.find(params[:id])
      end
    end
  end
end
