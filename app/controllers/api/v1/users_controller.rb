module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, only: [:show, :update, :destroy]
      before_action :run_validations, only: [:create, :update]
      before_action :check_username, only: [:create]
      skip_before_action :authorize_request, only: [:login, :application_login]
    
      def index
        @users = User.all
        render json: UserManagement::UserService.serialize_users(@users)
      end
      
      def show
        render json: UserManagement::UserService.find_user(@user.id)
      end
    
      def create
        birth_date_estimated = nil
        unless params[:age].blank?
          birth_date_estimated = UserManagement::UserService.calculate_birth_date_estimate(params[:age].to_i)
        end
        @user = UserManagement::UserService.create_user(first_name: params[:first_name], middle_name: params[:middle_name], last_name: params[:last_name], 
          sex: params[:sex], date_of_birth: params[:date_of_birth], birth_date_estimated: birth_date_estimated,  username: params[:username], 
          password: params[:password], roles: params[:roles], departments: params[:departments])
        render json: UserManagement::UserService.find_user(@user.id), status: :created
      end
    
      def update
        if @user.update(params)
          render json: @user
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end
    
      def destroy
        @user.destroy
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
    
      def run_validations
        unless params.has_key?('departments') && params[:departments].is_a?(Array)
          raise ActionController::ParameterMissing, MessageService::VALUE_NOT_ARRAY << " for departments"
        end
        unless params.has_key?('roles') && params[:roles].is_a?(Array)
          raise ActionController::ParameterMissing, MessageService::VALUE_NOT_ARRAY << " for roles"
        end
      end
      
      def check_username
        if UserManagement::UserService.username_exists?(params[:username])
          raise ActiveRecord::RecordNotUnique, "Username already exists"
        end
      end
    end
    
  end
end