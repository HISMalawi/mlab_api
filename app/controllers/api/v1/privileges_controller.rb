module Api
  module V1
    class PrivilegesController < ApplicationController
      before_action :set_privilege, only: [:show, :update, :destroy]
    
      def index
        @privileges = Privilege.all
        render json: @privileges
      end
      
      def show
        render json: @privilege
      end
    
      def create
        @privilege = Privilege.create!(privilege_params)
        render json: @privilege, status: :created
      end
    
      def update
        @privilege.update!(privilege_params)
        render json: @privilege
      end
    
      def destroy
        @privilege.void(params.require(:retired_reason))
        render json: {message: Message::RECORD_DELETED}
      end
    
      private
    
      def set_privilege
        @privilege = Privilege.find(params[:id])
      end
    
      def privilege_params
        params.require(:privilege).permit(:name)
      end
    end
    
  end 
end