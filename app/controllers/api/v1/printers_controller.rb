module Api
  module V1
    class PrintersController < ApplicationController
      before_action :set_printer, only: [:show, :update, :destroy]
    
      def index
        @printers = Printer.all
        render json: @printers
      end
      
      def show
        render json: @printer
      end
    
      def create
        @printer = Printer.create!(printer_params)
        render json: @printer, status: :created
      end
    
      def update
        @printer.update!(printer_params)
        render json: @printer
      end
    
      def destroy
        @printer.void(params.require(:voided_reason))
        render json: {message: MessageService::RECORD_DELETED}
      end
    
      private
    
      def set_printer
        @printer = Printer.find(params[:id])
      end

      def printer_params
        params.require(:printer).permit(:name, :description, :voided_reason)
      end
    end
  end
end
