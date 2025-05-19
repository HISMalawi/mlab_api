# frozen_string_literal: true
require 'tempfile'

# module Api
module Api
  # module V1
  module V1
    # stock item controller
    class StockItemsController < ApplicationController
      before_action :set_stock_item, only: %i[show update destroy]

      def index
        metadata = params[:metadata] == 'true'
        if metadata
          stock_items = Stock.joins(:stock_item)
            .joins(:stock_transactions)
            .group(
              'stock_items.id',
              'stocks.stock_location_id',
              'stocks.minimum_order_level',
              'stocks.quantity'
            )
            .select(
              'stock_items.*',
              'stocks.stock_location_id',
              'stocks.minimum_order_level',
              'stocks.quantity',
              "GROUP_CONCAT(DISTINCT stock_transactions.batch) as batches",
              "GROUP_CONCAT(DISTINCT stock_transactions.lot) as lots"
            )
            stock_items.each do |item|
              item.batches = item.batches.split(',') unless item.batches.nil?
              item.lots = item.lots.split(',') unless item.lots.nil?
            end
        else
          stock_items = Stock.joins(:stock_item)
            .select(
              'stock_items.*',
              'stocks.stock_location_id',
              'stocks.minimum_order_level',
              'stocks.quantity'
            )
        end
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
          unless file.content_type.in?(['text/csv', 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'])
            return render json: { error: 'Invalid file format. Please upload a CSV or Excel file.' }, status: :unprocessable_entity
          end

          if file.content_type == 'text/csv'
            begin
              temp_file = Tempfile.new(['utf8_converted', '.csv'], encoding: 'UTF-8')
              content = File.read(file.path, encoding: 'binary')
              utf8_content = content.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')

              temp_file.write(utf8_content)
              temp_file.close

              StockManagement::StockService.dump_products(temp_file.path)
            ensure
              temp_file.unlink if temp_file
            end
          else
            StockManagement::StockService.dump_products(file.path)
          end

          render json: { message: 'Import completed successfully!' }, status: :ok
        rescue StandardError => e
          Rails.logger.error("Import error: #{e.message}")
          Rails.logger.error(e.backtrace.join("\n"))
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end

      def show
        render json: StockManagement::StockService.stock_item(@stock_item)
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
          :product_code,
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
