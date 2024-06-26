# frozen_string_literal: true

module Api
  module V1
    # AuthController
    class AuthController < ApplicationController
      skip_before_action :authorize_request, only: %i[login application_login]

      def login
        payload = user_service.login(
          login_params[:username],
          login_params[:password],
          login_params[:department]
        )
        raise UnAuthorized, 'User is not authorized to access this department' if payload == false
        raise UnAuthorized, 'Invalid username or password' if payload.nil?

        render json: { authorization: payload }, status: :ok
      end

      def logout
        user_service.invalidate_token_version(User.current)
        render json: { message: 'Logged out successfully' }, status: :ok
      end

      def application_login
        payload = user_service.application_login(login_params[:username], login_params[:password])
        raise UnAuthorized, 'Invalid username or password' if payload.nil?

        render json: { authorization: payload }, status: :ok
      end

      def refresh_token
        render json: { authorization: user_service.refresh_token }, status: :ok
      end

      private

      def login_params
        params.permit(:username, :password, :department)
      end

      def user_service
        UserManagement::AuthService
      end
    end
  end
end
