module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authorize_request, only: [:login, :application_login]

      def login
        payload = UserManagement::AuthService.login(login_params[:username], login_params[:password], login_params[:department])
        raise UnAuthorized, 'User is not authorized to access this department' if payload == false
        raise UnAuthorized, 'Invalid username or password' if payload.nil?
        render json: {authorization: payload}, status: :ok
      end
    
      def application_login
        payload = UserManagement::AuthService.application_login(login_params[:username], login_params[:password])
        raise UnAuthorized, 'Invalid username or password' if payload.nil?
        render json: {authorization: payload}, status: :ok
      end
    
      def refresh_token
        render json: {authorization: UserManagement::AuthService.refresh_token}, status: :ok
      end

      private

      def login_params
        params.permit(:username, :password, :department)
      end
    end
  end
end