module Api
  module V1
    class StockCategoriesController < ApplicationController
      before_action :read, only: %i[ show update destroy ]
      def index
        stock_categories = StockCategory.all
        render json: stock_categories
      end
      def create
        category = StockCategory.create!(category_params)
        render json: { status: :ok, message: 'Stock category created successfully' }
      end
      def update
        @category = @category.update!(category_params)
        render json: { status: :ok, message: 'Stock category updated successfully' }
      end
      def destroy
        render json: @category.void(category_params[:voided_reason])
      end
      private
      def category_params
        params.require(:stock_category).permit(:id, :name, :description)
      end
      def read
        @category = StockCategory.find(params[:id])
      end
    end
  end
end
