module Api
  module V1
    class StockLocationsController < ApplicationController
      before_action :read, only: %i[ show update destroy ]
      def index
        stock_locations = StockLocation.all
        render json: stock_locations
      end
      def create
        location = StockLocation.create!(location_params)
        render json: { status: :ok, message: 'Stock location created successfully' }
      end
      def update
        @location = @location.update!(location_params)
        render json: { status: :ok, message: 'Stock location updated successfully' }
      end
      def destroy
        render json: @location.void(location_params[:voided_reason])
      end
      private
      def location_params
        params.require(:stock_location).permit(:id, :name, :description)
      end
      def read
        @location = StockLocation.find(params[:id])
      end
    end
  end
end
