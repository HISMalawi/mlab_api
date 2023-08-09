module Api
   module V1
     class StocksController < ApplicationController
      before_action :read, only: %i[ show update destroy ]
      def index
        stock = Stock.all
        render json: stock.to_json(include: [:stock_category, :stock_location])
      end
      def create
        stocks = Stock.create!(stock_params)
        render json: { message: 'Stock created successfully' }
      end
      def update()
        @stock = @stock.update!(stock_params)
        render json: { message: "Stock updated successfully" }
      end
      def destroy()
        @stock.void(params[:retired_reason])
        render json: { message: MessageService::RECORD_DELETED }
      end
      private
      def read
        @stock = Stock.find(params[:id])
      end
      def stock_params
        params.require(:stock).permit(:id, :name, :description, :lot, :unit, :stock_category_id, :stock_location_id)
      end
     end
   end
end
