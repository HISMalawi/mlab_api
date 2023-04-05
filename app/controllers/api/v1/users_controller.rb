module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, only: [:show, :update, :destroy]
      before_action :run_validations, only: [:create, :update]
      before_action :check_username, only: [:create]
      skip_before_action :authorize_request, only: [:login, :application_login]
    
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
        render json: UserManagement::UserService.find_user(@user.id)
      end
    
      def destroy
        @user.deactivate
        render json: {message: MessageService::RECORD_DELETED}
      end
    
      def login
        payload = UserManagement::AuthService.login(params[:username], params[:password], params[:department])
        raise UnAuthorized, 'User is not authorized to access this department' if payload == false
        raise UnAuthorized, 'Invalid username or password' if payload.nil?
        render json: {authorization: payload}, status: :ok
      end
    
      def application_login
        payload = UserManagement::AuthService.application_login(params[:username], params[:password])
        raise UnAuthorized, 'Invalid username or password' if payload.nil?
        render json: {authorization: payload}, status: :ok
      end
    
      def refresh_token
        render json: {authorization: UserManagement::AuthService.refresh_token}, status: :ok
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