module Api
  module V1
    class RolesController < ApplicationController
      before_action :set_role, only: [:show, :update, :destroy]
      before_action :check_privileges, only: [:create, :update]
    
      def index
        @roles = Role.all
        render json: UserManagement::RoleService.serialize_roles(@roles)
      end
      
      def show
        render json: UserManagement::RoleService.serialize_role(@role)
      end
    
      def create
        @role = UserManagement::RoleService.create_role(role_params)
        render json: UserManagement::RoleService.serialize_role(@role), status: :created
      end
    
      def update
        UserManagement::RoleService.update_role(@role, role_params)
        render json: UserManagement::RoleService.serialize_role(@role)
      end
    
      def update_permissions
        UserManagement::RoleService.update_permission(params[:role_privileges])
        render json: UserManagement::RoleService.serialize_roles(Role.all)
      end
    
      def destroy
        UserManagement::RoleService.delete_role(@role, params.require(:retired_reason))
        render json: {message: MessageService::RECORD_DELETED}
      end
    
      private
    
      def set_role
        @role = Role.find(params[:id])
      end
    
      def role_params
        params.permit(:name, privileges: [])
      end
    
      def check_privileges
        unless params.has_key?('privileges') && params[:privileges].is_a?(Array)
          raise ActionController::ParameterMissing, MessageService::VALUE_NOT_ARRAY << " for privileges"
        end
      end
    end
    
  end
end