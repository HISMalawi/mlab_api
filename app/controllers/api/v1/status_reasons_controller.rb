module Api
  module V1
    class StatusReasonsController < ApplicationController
      before_action :set_status_reason, only: [:show, :update, :destroy]
    
      def index
        @status_reasons = StatusReason.all
        render json: @status_reasons
      end
      
      def show
        render json: @status_reason
      end
    
      def create
        @status_reason = StatusReason.create!(status_reason_params)
        render json: @status_reason, status: :created
      end
    
      def update
        @status_reason.update!(status_reason_params)
        render json: @status_reason
      end
    
      def destroy
        @status_reason.void(params[:retired_reason])
        render json: {message: MessageService::RECORD_DELETED}
      end
    
      private
    
      def set_status_reason
        @status_reason = StatusReason.find(params[:id])
      end
    
      def status_reason_params
        params.require(:status_reason).permit(:description)
      end
    end
    
  end
end