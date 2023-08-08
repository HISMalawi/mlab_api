module Api
   module V1
     class StocksController < ApplicationController
      def create
        stocks = Stock.create!(stock_params)
        render json: stocks
      end

      def update()

      end

      def read()

      end

      def void()

      end

      private
      def stock_params
        params.require(:stock).permit(:name, :description, :lot, :unit, :stock_category_id, :stock_location_id)
      end
     end
   end
end
