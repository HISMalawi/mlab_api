module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, only: [:show, :update, :destroy, :activate, :change_username, :update_password]
      before_action :run_validations, only: [:create, :update]
      before_action :check_username, only: [:create]
    
      def index
        @users = User.all.page(params[:page]).per(params[:per_page])
        render json: UserManagement::UserService.serialize_users(@users)
      end
      
      def show
        render json: UserManagement::UserService.find_user(@user.id)
      end
    
      def create
        @user = UserManagement::UserService.create_user(user_params)
        render json: UserManagement::UserService.find_user(@user.id), status: :created
      end
    
      def update
        UserManagement::UserService.update_user(@user, user_params)
        unless @user.username == user_params[:user][:username]
          UserManagement::UserService.change_username(@user, user_params[:user][:username])
        end
        unless user_params[:user][:password].blank?
          UserManagement::UserService.update_password(@user, user_params[:user][:old_password], user_params[:user][:password])
        end
        render json: UserManagement::UserService.find_user(@user.id)
      end

      def update_password
        if @user.id == User.current.id
          raise ActionController::ParameterMissing, "for password" if params[:user][:password].blank?
          UserManagement::UserService.update_password(@user, user_params[:user][:old_password], user_params[:user][:password])
          render json: UserManagement::UserService.find_user(@user.id)
        else
          raise UnAuthorized, 'User not equal to logged in user'
        end
      end

      def change_username
        if @user.id == User.current.id
          UserManagement::UserService.change_username(@user, user_params[:user][:username])
          render json: UserManagement::UserService.find_user(@user.id)
        else
          raise UnAuthorized, 'User not equal to logged in user'
        end
      end
    
      def destroy
        @user.deactivate
        render json: {message: MessageService::RECORD_DELETED}
      end

      def activate
        @user.activate
        render json: {message: MessageService::RECORD_ACTIVATED}
      end
    
      private
    
      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.permit(user: %i[username password old_password], person: %i[first_name middle_name last_name sex date_of_birth], roles: [], departments: [])
      end
    
      def run_validations
        unless params.has_key?('departments') && params[:departments].is_a?(Array)
          raise ActionController::ParameterMissing, MessageService::VALUE_NOT_ARRAY << " for departments"
        end
        unless params.has_key?('roles') && params[:roles].is_a?(Array)
          raise ActionController::ParameterMissing, MessageService::VALUE_NOT_ARRAY << " for roles"
        end
      end
      
      def check_username
        if UserManagement::UserService.username_exists?(params[:user][:username])
          raise ActiveRecord::RecordNotUnique, "Username already exists"
        end
      end
    end
    
  end
end