# frozen_string_literal: true

# module Api
module Api
  # module V1
  module V1
    # stock unit controller
    class StockLocationsController < ApplicationController
      before_action :set_stock_location, only: %i[show update destroy]

      def index
        stock_locations = StockLocation.all
        render json: stock_locations
      end

      def create
        stock_location = StockLocation.create!(stock_location_params)
        render json: stock_location, status: :created
      end

      def show
        render json: @stock_location
      end

      def update
        @stock_location.update!(stock_location_params)
        render json: @stock_location, status: :ok
      end

      def destroy
        @stock_location.void(params.require(:reason))
        render json: {message: MessageService::RECORD_DELETED}
      end

      private

      def stock_location_params
        params.require(:stock_location).permit(:name)
      end

      def set_stock_location
        @stock_location = StockLocation.find(params[:id])
      end
    end
  end
end
