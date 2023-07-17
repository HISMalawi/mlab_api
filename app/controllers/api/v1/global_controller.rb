module Api
  module V1
    class GlobalController < ApplicationController
      skip_before_action :authorize_request, only: [:index,:update, :destroy, :show]
      before_action :set_global, only: [:update, :destroy, :show]

      def index
        render json: GlobalService.current_location
      end

      def create
        @global = Global.create!(global_params)
        Facility.find_or_create_by(name: @global.name)
        render json: @global, status: :created
      end

      def show
        render json: @global
      end
    
      def update
        facility = Facility.find_by_name(@global.name)
        @global.update!(global_params)
        facility.update!(name: global_params[:name])
        render json: @global
      end
    
      def destroy
        @global.void('No longer used')
        render json: {message: MessageService::RECORD_DELETED}
      end
    
      private
    
      def set_global
        @global = Global.find(params[:id])
      end
    
      def global_params
        params.require(:global).permit(:name, :code, :address, :phone, :district)
      end
      
    end
  end
end