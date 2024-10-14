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

      def import
        file = params[:file]
        if file.nil?
          return render json: { error: 'No file uploaded' }, status: :unprocessable_entity
        end

        begin
          dumpMRSProducts(file.path)
          render json: { message: 'Import completed successfully!' }, status: :ok
        rescue StandardError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
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

      def dumpMRSProducts(file_path)
        spreadsheet = Roo::Spreadsheet.open(file_path.to_s)
        header = spreadsheet.row(1)

        (2..spreadsheet.last_row).each do |i|
          row = Hash[[header, spreadsheet.row(i)].transpose]
          create_or_skip_stock_item(row)
        end
      end

      def create_or_skip_stock_item(row)
        ActiveRecord::Base.transaction do
          existing_stock_item = StockItem.find_by(name: row['name'])

          if existing_stock_item
            Rails.logger.info "Stock item '#{existing_stock_item.name}' already exists. Skipping..."
            next
          end

          stock_item = StockItem.create!(
            product_code: row['productCode'],
            name: row['name'],
            stock_category_id: StockCategory.find_or_create_by!(name: row['category']).id,
            description: row['description'],
            measurement_unit: StockUnit.find_or_create_by!(name: row['dispensable'].gsub('dispensingUnit:', '').strip).id,
            quantity_unit: row['packSize'],
            strength: row['Strength']
          )

          Stock.create!(
            stock_item_id: stock_item.id,
            stock_location_id: row['Stock Location ID'] || 1,
            quantity: 0,
            minimum_order_level: row['Minimum Order Level'] || 0
          )

          Rails.logger.info "Stock item '#{stock_item.name}' created successfully."
        end
      end

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
