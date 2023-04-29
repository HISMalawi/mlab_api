module Api
  module V1
    class GlobalController < ApplicationController
      skip_before_action :authorize_request, only: [:current_location]

      def index
        render json: GlobalService.current_location
      end

      def create
        @global = Global.create!(global_params)
        render json: @global, status: :created
      end
    
      def update
        @global.update!(global_params)
        render json: @global
      end
    
      def destroy
        @global.void(params[:retired_reason])
        render json: {message: MessageService::RECORD_DELETED}
      end
    
      private
    
      def set_global
        @global = Global.find(params[:id])
      end
    
      def global_params
        params.require(:global).permit(:name, :code, :address, :phone)
      end
      
    end
  end
end