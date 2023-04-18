module Api
  module V1
    class StatusesController < ApplicationController
      before_action :set_status, only: [:show, :update, :destroy]
    
      def index
        @statuses = Status.all
        render json: @statuses
      end
      
      def show
        render json: @status
      end
    
      def create
        @status = Status.create!(status_params)
        render json: @status, status: :created
      end
    
      def update
       @status.update!(status_params)
       render json: @status
      end
    
      def destroy
        @status.void(params[:retired_reason])
        render json: {message: MessageService::RECORD_DELETED}
      end
    
      private
    
      def set_status
       @status = Status.find(params[:id])
      end
    
      def status_params
        params.require(:status).permit(:name)
      end
    end    
  end
end