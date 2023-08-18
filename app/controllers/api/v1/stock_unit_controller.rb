# frozen_string_literal: true

# module Api
module Api
  # module V1
  module V1
    # stock unit controller
    class StockUnitController < ApplicationController
      def index
        stock_units = StockUnit.all
        render json: stock_units
      end

      def create
        stock_unit = StockUnit.new(stock_unit_params)
        if stock_unit.save
          render json: stock_unit, status: :created
        else
          render json: stock_unit.errors, status: :unprocessable_entity
        end
      end

      def update
        stock_unit = StockUnit.find(params[:id])
        if stock_unit.update(stock_unit_params)
          render json: stock_unit, status: :ok
        else
          render json: stock_unit.errors, status: :unprocessable_entity
        end
      end
    end

    def destroy
      stock_unit = StockUnit.find(params[:id])
      stock_unit.destroy
      head :no_content
    end

    private

    def stock_unit_params
      params.require(:stock_unit).permit(:name)
    end
  end
end
