# frozen_string_literal: true

# module Api
module Api
  # module V1
  module V1
    # stock unit controller
    class StockUnitsController < ApplicationController
      before_action :set_stock_unit, only: %i[show update destroy]

      def index
        stock_units = StockUnit.all
        render json: stock_units
      end

      def create
        stock_unit = StockUnit.create!(stock_unit_params)
        render json: stock_unit, status: :created
      end

      def show
        render json: @stock_unit
      end

      def update
        @stock_unit.update!(stock_unit_params)
        render json: @stock_unit, status: :ok
      end

      def destroy
        @stock_unit.void(params.require(:reason))
        render json: {message: MessageService::RECORD_DELETED}
      end

      private

      def stock_unit_params
        params.require(:stock_unit).permit(:name)
      end

      def set_stock_unit
        @stock_unit = StockUnit.find(params[:id])
      end
    end
  end
end
